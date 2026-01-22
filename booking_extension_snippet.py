
# --- EXTENSION FOR BOOKING DETAILS ---
from app.models.foodorder import FoodOrder, FoodOrderItem
from app.models.service_request import ServiceRequest
from app.models.inventory import StockIssue, StockIssueDetail, Location
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

# Define response models locally to avoid circular imports or missing modification in schemas
class FoodItemDetail(BaseModel):
    name: str
    quantity: int
    price: float

class FoodOrderSummary(BaseModel):
    id: int
    amount: float
    status: str
    created_at: datetime
    items: List[FoodItemDetail]

class ServiceRequestSummary(BaseModel):
    id: int
    request_type: str
    description: Optional[str]
    status: str
    created_at: datetime

class InventoryUsageSummary(BaseModel):
    item_name: str
    quantity: float
    unit: str
    issued_at: datetime

class BookingDetailsOut(BaseModel):
    id: int
    guest_name: str
    guest_mobile: Optional[str]
    guest_email: Optional[str]
    status: str
    check_in: str
    check_out: str
    room_number: str
    id_card_image_url: Optional[str]
    guest_photo_url: Optional[str]
    total_amount: float
    food_orders_total: float
    
    food_orders: List[FoodOrderSummary]
    service_requests: List[ServiceRequestSummary]
    inventory_usage: List[InventoryUsageSummary]

@router.get("/{booking_id}/details", response_model=BookingDetailsOut)
def get_booking_details_api(booking_id: int, db: Session = Depends(get_db)):
    # 1. Fetch Booking
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    # Get Room ID
    booking_room = db.query(BookingRoom).filter(BookingRoom.booking_id == booking.id).first()
    room_id = booking_room.room_id if booking_room else None
    room_number = "Unknown"
    
    if room_id:
        room = db.query(Room).filter(Room.id == room_id).first()
        if room:
            room_number = room.number
            
    # Define time range
    check_in_dt = datetime.combine(booking.check_in, datetime.min.time())
    check_out_dt = datetime.combine(booking.check_out, datetime.max.time())
    
    # 2. Fetch Food Orders
    food_orders_data = []
    food_total = 0.0
    if room_id:
        f_orders = db.query(FoodOrder).options(
            joinedload(FoodOrder.items).joinedload(FoodOrderItem.food_item)
        ).filter(
            FoodOrder.room_id == room_id,
            FoodOrder.created_at >= check_in_dt,
            FoodOrder.created_at <= check_out_dt
        ).order_by(FoodOrder.created_at.desc()).all()
        
        for fo in f_orders:
            food_total += (fo.total_with_gst or fo.amount or 0.0)
            items = []
            for item in fo.items:
                items.append(FoodItemDetail(
                    name=item.food_item_name or "Unknown Item",
                    quantity=item.quantity,
                    price=item.food_item.price if item.food_item else 0.0
                ))
            food_orders_data.append(FoodOrderSummary(
                id=fo.id,
                amount=fo.total_with_gst or fo.amount or 0.0,
                status=fo.status,
                created_at=fo.created_at,
                items=items
            ))

    # 3. Fetch Service Requests
    service_requests_data = []
    if room_id:
        s_requests = db.query(ServiceRequest).filter(
            ServiceRequest.room_id == room_id,
            ServiceRequest.created_at >= check_in_dt,
            ServiceRequest.created_at <= check_out_dt
        ).order_by(ServiceRequest.created_at.desc()).all()
        
        for sr in s_requests:
            service_requests_data.append(ServiceRequestSummary(
                id=sr.id,
                request_type=sr.request_type,
                description=sr.description,
                status=sr.status,
                created_at=sr.created_at
            ))

    # 4. Fetch Inventory Usage
    inventory_usage_data = []
    if room_id:
        # Try to find location by name matching room number
        loc = db.query(Location).filter(Location.name.contains(room_number)).first()
        
        if loc:
            issues = db.query(StockIssueDetail).join(StockIssue).filter(
                StockIssue.destination_location_id == loc.id,
                StockIssue.issue_date >= check_in_dt,
                StockIssue.issue_date <= check_out_dt
            ).options(joinedload(StockIssueDetail.item)).all()
            
            for issue in issues:
                inventory_usage_data.append(InventoryUsageSummary(
                    item_name=issue.item.name if issue.item else "Unknown",
                    quantity=issue.issued_quantity,
                    unit=issue.unit,
                    issued_at=issue.issue.issue_date
                ))

    return BookingDetailsOut(
        id=booking.id,
        guest_name=booking.guest_name,
        guest_mobile=booking.guest_mobile,
        guest_email=booking.guest_email,
        status=booking.status,
        check_in=str(booking.check_in),
        check_out=str(booking.check_out),
        room_number=room_number,
        id_card_image_url=booking.id_card_image_url,
        guest_photo_url=booking.guest_photo_url,
        total_amount=booking.total_amount or 0.0,
        food_orders_total=food_total,
        food_orders=food_orders_data,
        service_requests=service_requests_data,
        inventory_usage=inventory_usage_data
    )
