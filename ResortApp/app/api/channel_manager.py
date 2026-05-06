from fastapi import APIRouter, Depends, HTTPException, Request, Response
from sqlalchemy.orm import Session
from datetime import datetime
import os
import secrets
from typing import Dict, Any
import logging

from app.database import get_db
from app.models.booking import Booking, BookingRoom
from app.models.room import RoomType, Room
from app.api.booking import get_or_create_guest_user, format_display_id

logger = logging.getLogger(__name__)

router = APIRouter()

# Authenticate incoming requests from Aiosell
def verify_webhook_auth(request: Request):
    """Basic Auth checker for incoming webhooks"""
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        raise HTTPException(status_code=401, detail="Missing Authorization Header")
        
    expected_username = os.getenv("AIOSELL_WEBHOOK_USERNAME", "sandboxpms")
    expected_password = os.getenv("AIOSELL_WEBHOOK_PASSWORD", "sandboxpms")
    
    # Simple unsecure check for basic auth (Base64 decode in production, or just use secrets.compare_digest on header)
    import base64
    expected_b64 = base64.b64encode(f"{expected_username}:{expected_password}".encode()).decode()
    expected_auth = f"Basic {expected_b64}"
    
    if not secrets.compare_digest(auth_header, expected_auth):
        logger.warning(f"Failed webhook auth attempt. Header: {auth_header}")
        raise HTTPException(status_code=401, detail="Invalid Credentials")

@router.post("/webhook")
async def aiosell_webhook(
    request: Request,
    payload: Dict[Any, Any], 
    db: Session = Depends(get_db)
):
    """
    Inbound webhook for Aiosell Reservation Push
    Receives NEW, MODIFIED, CANCELLED reservations.
    """
    verify_webhook_auth(request)
    
    print(f"[AIOSELL WEBHOOK] FULL PAYLOAD: {payload}")
    logger.info(f"[AIOSELL WEBHOOK] Received payload: {payload}")
    
    reservation_id = payload.get("bookingID") or payload.get("bookingId")
    action = str(payload.get("action", "")).lower()
    channel_name = payload.get("channel", "OTA")
    
    if not reservation_id:
        logger.error(f"[AIOSELL WEBHOOK] Missing bookingID/bookingId in payload: {payload}")
        return Response(status_code=400, content="Missing bookingID or bookingId")
        
    # BRANCH logic -> Defaulting to standard branch 1 for sandbox integration
    branch_id = 1 
        
    if action == "book":
        return _handle_new_booking(payload, db, branch_id)
    elif action == "modify":
        return _handle_modify_booking(payload, db)
    elif action == "cancel":
        return _handle_cancel_booking(payload, db)
    else:
        logger.warning(f"[AIOSELL WEBHOOK] Unknown action: {action}")
        return {"success": True, "message": f"Ignored action {action}"}


def _map_room_type(db: Session, room_code: str, branch_id: int = None):
    """Helper to map Aiosell roomCode to Zeebull RoomType, optionally searching across all branches"""
    if not room_code:
        return None
        
    clean_code = str(room_code).strip().lower()
    
    # 1. Try with the specific branch first
    if branch_id:
        room_type = db.query(RoomType).filter(
            RoomType.channel_manager_id == room_code, 
            RoomType.branch_id == branch_id
        ).first()
        
        if not room_type:
            room_type = db.query(RoomType).filter(
                RoomType.name.ilike(clean_code.replace("-", " ")),
                RoomType.branch_id == branch_id
            ).first()
            
        if room_type:
            return room_type

    # 2. Global search if no specific branch match
    # Try exact CM ID first globally
    room_type = db.query(RoomType).filter(RoomType.channel_manager_id == room_code).first()
    
    # Try exact name match globally
    if not room_type:
        room_type = db.query(RoomType).filter(RoomType.name.ilike(clean_code.replace("-", " "))).first()
        
    # Try fuzzy match globally
    if not room_type:
        room_type = db.query(RoomType).filter(RoomType.name.ilike(f"%{clean_code}%")).first()
        
    if not room_type:
        logger.warning(f"[AIOSELL WEBHOOK] Failed to map roomCode '{room_code}' to any internal RoomType globally")
    else:
        logger.info(f"[AIOSELL WEBHOOK] Mapped roomCode '{room_code}' to RoomType ID {room_type.id} in Branch {room_type.branch_id}")
        
    return room_type

def _extract_amount(payload: dict) -> float:
    """Helper to extract total amount from various Aiosell/OTA payload formats"""
    # Try multiple root level keys
    keys = ["totalAmount", "total_amount", "amount", "total", "grandTotal", "total_price"]
    for k in keys:
        val = payload.get(k)
        if val is not None and not isinstance(val, dict):
            try:
                amt = float(val)
                print(f"[DEBUG-AIOSELL] Found total amount {amt} via key '{k}'")
                return amt
            except:
                continue
        
    # Try nested amount object
    amount_obj = payload.get("amount", {})
    if isinstance(amount_obj, dict):
        amt = (
            amount_obj.get("amountAfterTax") or 
            amount_obj.get("amount") or 
            amount_obj.get("total") or
            amount_obj.get("value")
        )
        if amt is not None:
            try:
                amt_val = float(amt)
                print(f"[DEBUG-AIOSELL] Found total amount {amt_val} via nested amount object")
                return amt_val
            except:
                pass
        
    print(f"[DEBUG-AIOSELL] Total amount not found in payload keys: {list(payload.keys())}")
    return 0.0
    
def _extract_channel(payload: dict) -> str:
    """Helper to extract channel name from various Aiosell/OTA formats"""
    channel = (
        payload.get("channel") or 
        payload.get("channelName") or 
        payload.get("source") or 
        payload.get("segment") or 
        "OTA"
    )
    # Standardize common values
    if str(channel).lower() == "direct":
        return "Direct"
    return channel

def _extract_room_rate(room_data: dict) -> float:
    """Helper to extract rate from a room object in the payload"""
    # 1. Try sellingPrice at room level
    for k in ["sellingPrice", "sellRate", "rate", "price", "amount"]:
        if k in room_data and not isinstance(room_data[k], (dict, list)):
            try:
                rate = float(room_data[k])
                print(f"[DEBUG-AIOSELL] Found room rate {rate} via key '{k}'")
                return rate
            except:
                continue
                
    # 2. Try prices array
    prices = room_data.get("prices", [])
    if prices and isinstance(prices, list):
        first_price = prices[0]
        if isinstance(first_price, dict):
            val = first_price.get("sellRate") or first_price.get("price") or first_price.get("amount")
            if val is not None:
                try:
                    rate = float(val)
                    print(f"[DEBUG-AIOSELL] Found room rate {rate} via prices array")
                    return rate
                except:
                    pass
                    
    print(f"[DEBUG-AIOSELL] Room rate not found in room_data keys: {list(room_data.keys())}")
    return 0.0

def _handle_new_booking(payload: dict, db: Session, branch_id: int):
    # Check if we already have it
    res_id = payload.get("bookingID") or payload.get("bookingId")
    existing = db.query(Booking).filter(Booking.external_id == res_id).first()
    # Best-effort guest info extraction across multiple possible objects
    guest_objs = [
        payload.get("guest"), 
        payload.get("customer"), 
        payload.get("primaryGuest"), 
        payload.get("traveller"), 
        payload.get("primary_guest"),
        payload.get("reservation", {}).get("guest"), # Some legacy formats
    ]
    
    print(f"[DEBUG-AIOSELL] ROOT KEYS: {list(payload.keys())}")
    
    name = "Aiosell Guest"
    email = None
    phone = None
    
    for i, obj in enumerate(guest_objs):
        if not obj or not isinstance(obj, dict):
            continue
            
        print(f"[DEBUG-AIOSELL] OBJ {i} KEYS: {list(obj.keys())}")
        print(f"[DEBUG-AIOSELL] OBJ {i} CONTENT: {obj}")
            
        # Try to get name if we don't have a good one yet
        f_name = str(obj.get("firstName") or obj.get("first_name") or obj.get("givenName") or "").replace("None", "").strip()
        l_name = str(obj.get("lastName") or obj.get("last_name") or obj.get("surname") or "").replace("None", "").strip()
        if (f_name or l_name) and name == "Aiosell Guest":
            name = f"{f_name} {l_name}".strip()
            
        # Try to get email if missing
        if not email:
            email = obj.get("email") or obj.get("email_address") or obj.get("emailAddress")
            
        # Try to get phone if missing
        if not phone:
            phone = (
                obj.get("phone") or 
                obj.get("mobile") or 
                obj.get("mobileNumber") or 
                obj.get("contactNumber") or
                obj.get("phoneNumber") or
                obj.get("contact_number")
            )
            
    # Fallback to root level keys if still missing
    email = email or payload.get("email")
    phone = phone or payload.get("phone") or payload.get("mobile") or payload.get("contactNumber") or payload.get("phoneNumber")
    
    print(f"[DEBUG-AIOSELL] BEST-EFFORT INFO: Name={name}, Email={email}, Phone={phone}")
    
    rooms = payload.get("rooms", [])
    room_type_id = None
    if rooms:
        primary_room_data = rooms[0]
        room_code = primary_room_data.get("roomCode")
        room_type = _map_room_type(db, room_code, branch_id)
        if room_type:
            room_type_id = room_type.id
            # Override branch_id based on where the room type is found
            branch_id = room_type.branch_id
            
    # Extract Rate Plan and Price Details
    rate_plan_code = None
    room_rate = 0.0
    if rooms:
        primary = rooms[0]
        rate_plan_code = primary.get("rateplanCode")
        room_rate = _extract_room_rate(primary)
            
    special_requests = payload.get("specialRequests") or payload.get("notes")
             
    # Parse dates
    try:
        check_in = datetime.strptime(payload.get("checkin"), "%Y-%m-%d").date()
        check_out = datetime.strptime(payload.get("checkout"), "%Y-%m-%d").date()
    except Exception as e:
        logger.error(f"[AIOSELL] Date parsing error: {e}")
        return Response(status_code=400, content="Invalid date format")

    # 2. Get Guest User
    user_id = None
    try:
        if email or phone:
            user_id = get_or_create_guest_user(db, email, phone, name, branch_id)
    except Exception as e:
        logger.error(f"[AIOSELL] User creation error: {e}")
        
    num_rooms = len(rooms)
    total_adults = sum([int(r.get("occupancy", {}).get("adults", 1)) for r in rooms])
    total_children = sum([int(r.get("occupancy", {}).get("children", 0)) for r in rooms])
    
    # Extract total amount
    total_amount = _extract_amount(payload)
    
    advance_deposit = 0.0 
    if str(payload.get("pah", "True")).lower() == "false":
        advance_deposit = total_amount
        
    # 3. Create Booking
    db_booking = Booking(
        guest_name=name,
        guest_mobile=phone,
        guest_email=email,
        check_in=check_in,
        check_out=check_out,
        adults=total_adults,
        children=total_children,
        room_type_id=room_type_id,
        source=_extract_channel(payload),
        external_id=res_id,
        user_id=user_id,
        branch_id=branch_id,
        status="Booked",
        num_rooms=num_rooms,
        total_amount=total_amount,
        advance_deposit=advance_deposit,
        room_rate=room_rate,
        rate_plan_code=rate_plan_code,
        special_requests=special_requests
    )
    
    db.add(db_booking)
    db.commit()
    db.refresh(db_booking)
    
    db_booking.display_id = format_display_id(db_booking.id, branch_id=branch_id)
    db.commit()
    
    logger.info(f"[AIOSELL WEBHOOK] Created Booking {db_booking.display_id} from {res_id}")
    return {"success": True, "booking_id": db_booking.id, "display_id": db_booking.display_id}

def _handle_modify_booking(payload: dict, db: Session):
    res_id = payload.get("bookingID") or payload.get("bookingId")
    booking = db.query(Booking).filter(Booking.external_id == res_id).first()
    
    # Best-effort update Guest Info
    guest_objs = [
        payload.get("guest"), 
        payload.get("customer"), 
        payload.get("primaryGuest"), 
        payload.get("traveller"), 
        payload.get("primary_guest")
    ]
    
    new_email = None
    new_phone = None
    new_name = None
    
    for obj in guest_objs:
        if not obj or not isinstance(obj, dict):
            continue
            
        f_name = str(obj.get("firstName") or obj.get("first_name") or obj.get("givenName") or "").replace("None", "").strip()
        l_name = str(obj.get("lastName") or obj.get("last_name") or obj.get("surname") or "").replace("None", "").strip()
        if (f_name or l_name) and not new_name:
            new_name = f"{f_name} {l_name}".strip()
            
        if not new_email:
            new_email = obj.get("email") or obj.get("email_address") or obj.get("emailAddress")
            
        if not new_phone:
            new_phone = (
                obj.get("phone") or 
                obj.get("mobile") or 
                obj.get("mobileNumber") or 
                obj.get("contactNumber") or
                obj.get("phoneNumber") or
                obj.get("contact_number")
            )

    if new_name:
        booking.guest_name = new_name
    
    booking.guest_email = new_email or payload.get("email") or booking.guest_email
    booking.guest_mobile = (
        new_phone or 
        payload.get("phone") or 
        payload.get("mobile") or 
        booking.guest_mobile
    )
    
    print(f"[DEBUG-AIOSELL-MODIFY] BEST-EFFORT UPDATED INFO: Name={booking.guest_name}, Email={booking.guest_email}, Phone={booking.guest_mobile}")
        
    # Apply modifications
    rooms = payload.get("rooms", [])
    if rooms:
        primary = rooms[0]
        try:
            booking.check_in = datetime.strptime(payload.get("checkin"), "%Y-%m-%d").date()
            booking.check_out = datetime.strptime(payload.get("checkout"), "%Y-%m-%d").date()
            booking.num_rooms = len(rooms)
            booking.adults = sum([int(r.get("occupancy", {}).get("adults", 1)) for r in rooms])
            booking.children = sum([int(r.get("occupancy", {}).get("children", 0)) for r in rooms])
            
            # UPDATE ROOM TYPE
            room_code = primary.get("roomCode")
            room_type = _map_room_type(db, room_code, booking.branch_id)
            if room_type:
                booking.room_type_id = room_type.id
                # Update branch if needed (though usually modification stays in branch)
                booking.branch_id = room_type.branch_id
                
            # UPDATE RATE AND PRICE
            booking.rate_plan_code = primary.get("rateplanCode")
            booking.room_rate = _extract_room_rate(primary)
                
            booking.special_requests = payload.get("specialRequests") or payload.get("notes")
        except Exception as e:
            logger.error(f"[AIOSELL] Error during modify extraction: {e}")
            
    # Update amount and channel
    booking.total_amount = _extract_amount(payload)
    booking.source = _extract_channel(payload)
    
    db.commit()
    logger.info(f"[AIOSELL WEBHOOK] Modified Booking {booking.display_id} (External: {res_id}, RoomType: {booking.room_type_id}, Rate: {booking.room_rate})")
    return {"success": True, "message": "Modified"}

def _handle_cancel_booking(payload: dict, db: Session):
    res_id = payload.get("bookingID") or payload.get("bookingId")
    booking = db.query(Booking).filter(Booking.external_id == res_id).first()
    
    if not booking:
        return {"success": True, "message": "Already cancelled/missing"}
        
    booking.status = "Cancelled"
    
    # Try to clean up physical room links if assigned
    if booking.booking_rooms:
        for br in booking.booking_rooms:
            room = br.room
            if room and room.status == "Booked":
                room.status = "Available"
        
        # Delete links
        db.query(BookingRoom).filter(BookingRoom.booking_id == booking.id).delete()
        
    db.commit()
    logger.info(f"[AIOSELL WEBHOOK] Cancelled Booking {booking.display_id} from {res_id}")
    return {"success": True, "message": "Cancelled"}
