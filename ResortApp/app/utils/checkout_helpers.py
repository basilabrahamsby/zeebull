"""
Helper functions for comprehensive checkout system
"""
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import timezone, datetime, date, time
from typing import List, Dict, Optional
from app.models.inventory import InventoryItem, InventoryTransaction, Location
from app.models.room import Room
from app.models.checkout import CheckoutVerification, CheckoutPayment
from app.schemas.checkout import ConsumableAuditItem, AssetDamageItem, RoomVerificationData, SplitPaymentItem
import re

def calculate_consumable_charge(inv_item, used_qty, limit_from_audit=None):
    """
    Unified logic to calculate charge for a consumable item.
    - Amenities (water, etc.) get a default limit of 2 if not set.
    - Respects is_sellable_to_guest flag.
    - Calculates replacement price (Selling Price or Cost + GST).
    """
    clean_name = inv_item.name
    # Remove quantity suffix if any
    clean_name = re.sub(r'\s*\(\s*[xX]\d+[^)]*\)', '', clean_name).strip()
    
    limit = limit_from_audit if limit_from_audit is not None else (inv_item.complimentary_limit or 0)
    is_amenity = any(kw in clean_name.lower() for kw in ["water", "soap", "shampoo", "amenity"])
    
    # SQLAlchemy boolean handling: 0 is False, 1 is True, None is treated as False by default in our logic
    is_sellable = bool(getattr(inv_item, 'is_sellable_to_guest', False))
    
    # If the attribute is missing, we might want a different default, but model says default=False
    # However, for backward compatibility or if not explicitly set, let's check:
    if getattr(inv_item, 'is_sellable_to_guest', None) is None:
        # If explicitly NULL, we check if it has a selling price
        is_sellable = (inv_item.selling_price or 0) > 0

    chargeable_qty = 0
    if is_amenity:
        # User Instruction: "there are no free limits... items that are set as complimentary will not be charged"
        # We rely strictly on the passed 'limit' (which should represent the complimentary allocation)
        # or the Master Data limit. We do NOT effectively force a minimum of 2.
        effective_limit = limit
        chargeable_qty = max(0, used_qty - effective_limit)
    else:
        # Non-amenities (Soda, Snacks, etc.)
        if not is_sellable and limit == 0:
            # If item is marked as "Not Sellable" and no limit is explicitly set,
            # it's likely a complimentary item not categorized as a basic amenity
            chargeable_qty = 0
        else:
            chargeable_qty = max(0, used_qty - limit)
            
    # Calculate price
    selling_price = float(inv_item.selling_price or 0.0)
    replacement_price = selling_price if selling_price > 0 else (float(inv_item.unit_price or 0.0) * (1.0 + float(inv_item.gst_rate or 0.0) / 100.0))
    
    return chargeable_qty * replacement_price, replacement_price, chargeable_qty


def calculate_late_checkout_fee(booking_checkout_date: date, actual_checkout_time: Optional[datetime], 
                                room_rate: float, late_checkout_threshold_hour: int = 12) -> float:
    """
    Calculate late checkout fee (50% of room rate if checkout after threshold hour)
    """
    if not actual_checkout_time:
        return 0.0
    
    actual_date = actual_checkout_time.date()
    actual_hour = actual_checkout_time.hour
    
    # If checkout is on a different day than booking checkout date, it's definitely late
    if actual_date > booking_checkout_date:
        return room_rate * 0.5
    
    # If same day but after threshold hour, charge late fee
    if actual_date == booking_checkout_date and actual_hour >= late_checkout_threshold_hour:
        return room_rate * 0.5
    
    return 0.0


def process_consumables_audit(db: Session, room_id: int, consumables: List[ConsumableAuditItem]) -> Dict:
    """
    Process consumables audit and calculate charges
    Returns: {total_charge: float, items_charged: List[Dict]}
    """
    total_charge = 0.0
    items_charged = []
    
    for item in consumables:
        # Get inventory item to verify
        inv_item = db.query(InventoryItem).filter(InventoryItem.id == item.item_id).first()
        if not inv_item:
            continue
        
        # Calculate charge for items consumed beyond complimentary limit using unified helper
        charge, unit_price, excess_quantity = calculate_consumable_charge(inv_item, item.actual_consumed, limit_from_audit=item.complimentary_limit)
        total_charge += charge
            
        items_charged.append({
            "item_id": item.item_id,
            "item_name": item.item_name,
            "complimentary_limit": item.complimentary_limit,
            "actual_consumed": item.actual_consumed,
            "excess_quantity": excess_quantity,
            "charge_per_unit": unit_price,
            "total_charge": charge
        })
    
    return {
        "total_charge": total_charge,
        "items_charged": items_charged
    }


def process_asset_damage_check(asset_damages: List[AssetDamageItem]) -> Dict:
    """
    Process asset damage check and calculate replacement costs
    Returns: {total_charge: float, damages: List[Dict]}
    """
    total_charge = sum(damage.replacement_cost for damage in asset_damages)
    damages = [
        {
            "item_name": damage.item_name,
            "replacement_cost": damage.replacement_cost,
            "notes": damage.notes
        }
        for damage in asset_damages
    ]
    
    return {
        "total_charge": total_charge,
        "damages": damages
    }


def deduct_room_consumables(db: Session, room_id: int, consumables: List[ConsumableAuditItem], 
                           checkout_id: int, created_by: Optional[int] = None, branch_id: Optional[int] = None):
    """
    Deduct consumed items from room inventory
    """
    room = db.query(Room).filter(Room.id == room_id).first()
    if not room or not room.inventory_location_id:
        return
    
    location = db.query(Location).filter(Location.id == room.inventory_location_id).first()
    if not location:
        return
    
    for item in consumables:
        inv_item = db.query(InventoryItem).filter(InventoryItem.id == item.item_id).first()
        if not inv_item:
            continue
        
        # Deduct actual consumed quantity from ROOM inventory (LocationStock)
        # NOT from global/warehouse stock (InventoryItem.current_stock) which was already deducted during StockIssue
        quantity_to_deduct = item.actual_consumed
        
        if quantity_to_deduct > 0:
            from app.models.inventory import LocationStock
            
            loc_stock = db.query(LocationStock).filter(
                LocationStock.location_id == room.inventory_location_id,
                LocationStock.item_id == item.item_id
            ).first()
            
            if loc_stock:
                if loc_stock.quantity >= quantity_to_deduct:
                    loc_stock.quantity -= quantity_to_deduct
                    loc_stock.last_updated = datetime.now(timezone.utc)
                else:
                    # Logic if consumed more than stock (possible if stock tracking was off)
                    # Force update or just set to 0? Let's allow negative or just zero out?
                    # Safer to just deduct and let it go negative if needed to track discrepancy, 
                    # but for now let's just deduct.
                    loc_stock.quantity -= quantity_to_deduct
                    loc_stock.last_updated = datetime.now(timezone.utc)
            
            # Create inventory transaction
            # Transaction type "out" implies consumption/removal from asset list
            transaction = InventoryTransaction(
                item_id=item.item_id,
                transaction_type="out",
                quantity=quantity_to_deduct,
                unit_price=inv_item.unit_price or 0.0,
                total_amount=(inv_item.unit_price or 0.0) * quantity_to_deduct,
                reference_number=f"CHECKOUT-{checkout_id}",
                notes=f"Checkout consumption - Room {room.number if room else 'N/A'}",
                created_by=created_by,
                source_location_id=room.inventory_location_id,
                branch_id=branch_id
            )
            db.add(transaction)


def trigger_linen_cycle(db: Session, room_id: int, checkout_id: int, branch_id: Optional[int] = None):
    """
    Move bed sheets and towels to laundry queue (dirty status)
    Logic: Find all linen items in room inventory and move them to laundry location
    """
    from app.models.inventory import LaundryLog, LocationStock
    
    room = db.query(Room).filter(Room.id == room_id).first()
    if not room or not room.inventory_location_id:
        return
    
    # 1. Find Laundry Location
    laundry_loc = db.query(Location).filter(Location.location_type == "LAUNDRY").first()
    if not laundry_loc:
        # Create it if it doesn't exist
        laundry_loc = Location(
            name="Laundry",
            building="Main Building",
            room_area="Laundry Service",
            location_type="LAUNDRY",
            is_inventory_point=True,
            branch_id=branch_id
        )
        db.add(laundry_loc)
        db.flush()
    
    # 2. Find all linen items with stock in this room
    # We join with InventoryItem to check track_laundry_cycle
    linen_stocks = db.query(LocationStock).join(InventoryItem).filter(
        LocationStock.location_id == room.inventory_location_id,
        InventoryItem.track_laundry_cycle == True,
        LocationStock.quantity > 0
    ).all()
    
    for stock in linen_stocks:
        qty = stock.quantity
        item_id = stock.item_id
        
        # 3. Create LaundryLog
        laundry_log = LaundryLog(
            item_id=item_id,
            source_location_id=room.inventory_location_id,
            room_number=room.number,
            quantity=qty,
            status="Incomplete Washing",
            sent_at=datetime.now(timezone.utc),
            branch_id=branch_id
        )
        db.add(laundry_log)
        
        # 4. Move Stock
        # Decrease Room stock
        stock.quantity = 0
        
        # Increase Laundry stock
        target_stock = db.query(LocationStock).filter(
            LocationStock.location_id == laundry_loc.id,
            LocationStock.item_id == item_id
        ).first()
        
        if not target_stock:
            target_stock = LocationStock(
                location_id=laundry_loc.id,
                item_id=item_id,
                quantity=0,
                branch_id=branch_id
            )
            db.add(target_stock)
        
        target_stock.quantity += qty
        
        # 5. Log Transaction
        transaction = InventoryTransaction(
            item_id=item_id,
            transaction_type="transfer",
            quantity=qty,
            unit_price=0.0,
            reference_number=f"LAUNDRY-{checkout_id}",
            notes=f"Linen to Laundry - Room {room.number}",
            created_by=None,
            source_location_id=room.inventory_location_id,
            destination_location_id=laundry_loc.id,
            branch_id=branch_id
        )
        db.add(transaction)


def create_checkout_verification(db: Session, checkout_id: int, room_verification: RoomVerificationData, room_id: Optional[int] = None, branch_id: Optional[int] = None) -> CheckoutVerification:
    """
    Create checkout verification record for a room
    """
    # Get room_id if not provided
    if not room_id:
        from app.models.room import Room
        room = db.query(Room).filter(Room.number == room_verification.room_number).first()
        room_id = room.id if room else None
    
    # Process consumables audit
    consumables_audit = process_consumables_audit(
        db, 
        room_id=room_id or 0,  # Use room_id if available
        consumables=room_verification.consumables
    )
    
    # Process asset damages
    asset_damage = process_asset_damage_check(room_verification.asset_damages)
    
    # Calculate key card fee (if not returned)
    key_card_fee = 0.0 if room_verification.key_card_returned else 50.0  # Default fee
    
    verification = CheckoutVerification(
        checkout_id=checkout_id,
        room_number=room_verification.room_number,
        housekeeping_status=room_verification.housekeeping_status,
        housekeeping_notes=room_verification.housekeeping_notes,
        consumables_audit_data={
            item.item_id: {
                "actual": item.actual_consumed,
                "issued": getattr(item, 'issued_qty', item.actual_consumed), # Fallback for legacy
                "limit": item.complimentary_limit,
                "charge": item.total_charge,
                "is_rentable": getattr(item, 'is_rentable', False),
                "missing": getattr(item, 'missing_qty', 0)
            }
            for item in room_verification.consumables
        },
        consumables_total_charge=consumables_audit["total_charge"],
        asset_damages=[
            {
                "item_name": d.item_name,
                "replacement_cost": d.replacement_cost,
                "notes": d.notes
            }
            for d in room_verification.asset_damages
        ],
        asset_damage_total=asset_damage["total_charge"],
        key_card_returned=room_verification.key_card_returned,
        key_card_fee=key_card_fee,
        branch_id=branch_id
    )
    
    db.add(verification)
    return verification


def process_split_payments(db: Session, checkout_id: int, split_payments: List[SplitPaymentItem], branch_id: Optional[int] = None) -> List[CheckoutPayment]:
    """
    Create payment records for split payments
    """
    payment_records = []
    for payment in split_payments:
        payment_record = CheckoutPayment(
            checkout_id=checkout_id,
            payment_method=payment.payment_method,
            amount=payment.amount,
            transaction_id=payment.transaction_id,
            notes=payment.notes,
            branch_id=branch_id
        )
        db.add(payment_record)
        payment_records.append(payment_record)
    
    return payment_records


def generate_invoice_number(db: Session) -> str:
    """
    Generate unique invoice number (e.g., INV-2025-001234)
    """
    today = date.today()
    year = today.year
    month = today.month
    
    # Get count of invoices this month
    from app.models.checkout import Checkout
    count = db.query(Checkout).filter(
        func.extract('year', Checkout.created_at) == year,
        func.extract('month', Checkout.created_at) == month
    ).count()
    
    invoice_number = f"INV-{year}-{str(count + 1).zfill(6)}"
    return invoice_number


def calculate_gst_breakdown(
    db: Session, 
    branch_id: int, 
    room_charges: float, 
    food_charges: float, 
    package_charges: float, 
    service_charges: float = 0.0, 
    consumables_charges: float = 0.0, 
    inventory_charges: float = 0.0, 
    nights: int = 1,
    use_night_charges: bool = False,
    booking_id: int = None
) -> Dict:
    """
    Calculate GST breakdown with dynamic rates from branch settings.
    Respects the gst_enabled toggle.
    Room GST is slab-based depending on daily price range, or derived from NightCharge if enabled.
    """
    from app.utils.settings_helpers import get_gst_settings
    from app.models.day_audit import NightCharge
    
    gst_settings = get_gst_settings(db, branch_id)
    
    # If GST is disabled globally for this branch, return zero
    if not gst_settings.get("gst_enabled", False):
        return {
            "room_gst": 0.0,
            "food_gst": 0.0,
            "package_gst": 0.0,
            "service_gst": 0.0,
            "consumables_gst": 0.0,
            "inventory_gst": 0.0,
            "total_gst": 0.0
        }
    
    # Room GST Logic
    room_gst = 0.0
    room_gst_rate = 0.0
    
    if use_night_charges and booking_id:
        # Sum pre-posted nightly charges with their locked GST rates
        night_charges = db.query(NightCharge).filter(
            NightCharge.booking_id == booking_id,
            NightCharge.is_reversed == False
        ).all()
        if night_charges:
            room_gst = sum(nc.gst_amount for nc in night_charges)
            # Calculate an effective room_gst_rate for package_gst if needed
            total_room_charge = sum(nc.room_charge for nc in night_charges)
            if total_room_charge > 0:
                room_gst_rate = room_gst / total_room_charge
            else:
                room_gst_rate = 0.0
    
    if room_gst == 0.0 and room_charges > 0:
        if gst_settings.get("gst_room_type") == "MANUAL":
            room_gst_rate = float(gst_settings.get("room_gst_rate", 0)) / 100.0
        else:
            # Slab-based Logic (Default)
            daily_rate = (room_charges + package_charges) / max(1, nights)
            
            r1 = float(gst_settings.get("gst_slab_rate_1", 5)) / 100.0
            r2 = float(gst_settings.get("gst_slab_rate_2", 12)) / 100.0
            r3 = float(gst_settings.get("gst_slab_rate_3", 18)) / 100.0
            
            room_gst_rate = r3
            if daily_rate < 5000:
                room_gst_rate = r1
            elif daily_rate < 7500:
                room_gst_rate = r2
            
        room_gst = room_charges * room_gst_rate
    
    # Package GST (usually same as room rate)
    package_gst = package_charges * room_gst_rate
    
    # Food GST
    food_rate = float(gst_settings["food_gst_rate"]) / 100.0
    food_gst = food_charges * food_rate
    
    # Service GST
    service_rate = float(gst_settings["service_gst_rate"]) / 100.0
    service_gst = service_charges * service_rate
    
    # Consumables (usually same as food rate or service rate, let's use food rate as default)
    consumables_gst = consumables_charges * food_rate
    
    # Inventory (usually same as service rate)
    inventory_gst = inventory_charges * service_rate
    
    total_gst = room_gst + food_gst + package_gst + service_gst + consumables_gst + inventory_gst
    
    return {
        "room_gst": room_gst,
        "food_gst": food_gst,
        "package_gst": package_gst,
        "service_gst": service_gst,
        "consumables_gst": consumables_gst,
        "inventory_gst": inventory_gst,
        "total_gst": total_gst
    }
