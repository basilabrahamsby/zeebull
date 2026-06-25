from pydantic import BaseModel, validator, field_validator, model_validator, EmailStr
import re
from typing import List, Optional, Union
from datetime import date, datetime
from .user import UserOut
from .checkout import CheckoutFull
from .payment import PaymentOut

# This schema is used for displaying Room details within a Booking
class RoomOut(BaseModel):
    id: int
    number: str
    room_type_id: Optional[int] = None
    type: Optional[str] = None     # resolved from RoomType.name via @property
    status: str
    image_url: Optional[str] = None
    inventory_location_id: Optional[int] = None

    class Config:
        from_attributes = True

# This schema represents the link between a Booking and a Room
class BookingRoomOut(BaseModel):
    booking_id: int
    room_id: int
    room: RoomOut

    class Config:
        from_attributes = True


class BookingUpdate(BaseModel):
    guest_name: Optional[str] = None
    guest_mobile: Optional[str] = None
    guest_email: Optional[str] = None
    adults: Optional[int] = None
    children: Optional[int] = None
    check_in: Optional[date] = None
    check_out: Optional[date] = None
    gst_number: Optional[str] = None
    source: Optional[str] = None
    total_amount: Optional[float] = None
    room_rate: Optional[float] = None
    room_type_id: Optional[int] = None
    num_rooms: Optional[int] = None
    room_ids: Optional[List[int]] = None

# This schema is used when creating a new booking
class BookingCreate(BaseModel):
    room_ids: List[int] = []
    room_type_id: Optional[int] = None
    source: str = "Admin"
    external_id: Optional[str] = None
    guest_name: str
    guest_mobile: str
    guest_email: Optional[EmailStr] = None
    check_in: date
    check_out: date
    adults: int
    children: int
    num_rooms: int = 1
    branch_id: Optional[int] = None
    custom_room_rate: Optional[float] = None
    pan_number: Optional[str] = None  # Optional PAN for GST verification
    gst_number: Optional[str] = None  # Guest GST Number


    @validator('pan_number')
    def validate_pan(cls, v):
        if v is None or v == '':
            return None
        pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]$'
        if not re.fullmatch(pattern, v):
            raise ValueError('Invalid PAN format')
        return v
    def blank_email_to_none(cls, v):
        if v == "" or v is None:
            return None
        return v

    @validator('check_out')
    def validate_booking_duration(cls, v, values):
        """Ensure minimum booking duration of 1 day"""
        if 'check_in' in values:
            check_in = values['check_in']
            if v <= check_in:
                raise ValueError('Check-out date must be at least 1 day after check-in date')
        return v

# This is the main output schema for displaying bookings
class BookingOut(BaseModel):
    id: int
    display_id: Optional[str] = None  # Format: BK-000001
    guest_name: str
    guest_mobile: Optional[str] = None
    guest_email: Optional[str] = None
    status: str
    branch_id: Optional[int] = None
    check_in: date
    check_out: date
    adults: int
    children: int
    num_rooms: int = 1
    checked_in_at: Optional[datetime] = None
    checked_out_at: Optional[datetime] = None
    checkout: Optional[CheckoutFull] = None
    # --- CRITICAL FIX: Add the missing image URL fields ---
    id_card_image_url: Optional[str] = None
    guest_photo_url: Optional[str] = None
    pan_number: Optional[str] = None
    gst_number: Optional[str] = None
    user: Optional[UserOut] = None
    is_package: bool = False
    total_amount: float = 0.0
    advance_deposit: float = 0.0
    source: Optional[str] = "Direct"
    package_name: Optional[str] = None
    room_type_id: Optional[Union[int, str]] = None       # For soft-allocation bookings
    room_type_name: Optional[str] = None     # Resolved room type name
    room_rate: float = 0.0
    rate_plan_code: Optional[str] = None
    
    is_confirmed: bool = False
    confirmed_at: Optional[datetime] = None
    confirmation_notes: Optional[str] = None
    
    is_id_verified: bool = False
    digital_signature_url: Optional[str] = None
    special_requests: Optional[str] = None
    preferences: Optional[str] = None
    rooms: List[RoomOut] = []
    created_at: Optional[datetime] = None # Added for sorting
    
    # Detailed arrays
    food_orders: List[object] = []
    service_requests: List[object] = []
    inventory_usage: List[object] = []
    payments: List[PaymentOut] = []
    
    @model_validator(mode='after')
    def set_display_id(self):
        """Auto-generate display_id if not provided"""
        if not self.display_id:
            self.display_id = f"BK-{str(self.id).zfill(6)}"
        return self

    class Config:
        from_attributes = True

class PaymentEntry(BaseModel):
    amount: float
    method: str  # upi, card, cash

class BookingConfirm(BaseModel):
    payments: List[PaymentEntry] = []
    notes: Optional[str] = None
