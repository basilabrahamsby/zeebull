from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.calendar import PricingCalendar
from app.schemas.calendar import PricingCalendarCreate, PricingCalendarUpdate, PricingCalendarOut
from typing import List
from datetime import date

router = APIRouter(tags=["Pricing Calendar"])

@router.post("/", response_model=PricingCalendarOut)
def create_calendar_entry(entry: PricingCalendarCreate, db: Session = Depends(get_db)):
    if entry.start_date > entry.end_date:
        raise HTTPException(status_code=400, detail="start_date cannot be after end_date.")
    new_entry = PricingCalendar(**entry.model_dump())
    db.add(new_entry)
    db.commit()
    db.refresh(new_entry)
    return new_entry

@router.get("/", response_model=List[PricingCalendarOut])
def get_calendar_entries(db: Session = Depends(get_db)):
    return db.query(PricingCalendar).all()

@router.get("/{entry_id}", response_model=PricingCalendarOut)
def get_calendar_entry(entry_id: int, db: Session = Depends(get_db)):
    db_entry = db.query(PricingCalendar).filter(PricingCalendar.id == entry_id).first()
    if not db_entry:
        raise HTTPException(status_code=404, detail="Entry not found.")
    return db_entry

@router.put("/{entry_id}", response_model=PricingCalendarOut)
def update_calendar_entry(entry_id: int, entry: PricingCalendarUpdate, db: Session = Depends(get_db)):
    db_entry = db.query(PricingCalendar).filter(PricingCalendar.id == entry_id).first()
    if not db_entry:
        raise HTTPException(status_code=404, detail="Entry not found.")
    
    update_data = entry.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_entry, key, value)
        
    db.commit()
    db.refresh(db_entry)
    return db_entry

@router.delete("/{entry_id}", response_model=dict)
def delete_calendar_entry(entry_id: int, db: Session = Depends(get_db)):
    db_entry = db.query(PricingCalendar).filter(PricingCalendar.id == entry_id).first()
    if not db_entry:
        raise HTTPException(status_code=404, detail="Entry not found.")
    
    db.delete(db_entry)
    db.commit()
    return {"message": "Entry deleted successfully"}
