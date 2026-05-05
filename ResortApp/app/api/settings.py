from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List, Any
from datetime import datetime

from app.utils.auth import get_db, get_current_user
from app.utils.branch_scope import get_branch_id
from app.models.settings import SystemSetting

router = APIRouter(tags=["Settings"])

class SettingBase(BaseModel):
    key: str
    value: Optional[str] = None
    description: Optional[str] = None

class SettingOut(SettingBase):
    id: int
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

@router.get("", response_model=List[SettingOut])
@router.get("/", response_model=List[SettingOut], include_in_schema=False)
def get_settings(
    db: Session = Depends(get_db), 
    branch_id: int = Depends(get_branch_id),
    current_user: dict = Depends(get_current_user)
):
    print(f"Fetching settings for branch: {branch_id}")
    return db.query(SystemSetting).filter(SystemSetting.branch_id == branch_id).all()

@router.post("", response_model=SettingOut)
@router.post("/", response_model=SettingOut, include_in_schema=False)
def create_or_update_setting(
    setting_in: SettingBase, 
    db: Session = Depends(get_db), 
    branch_id: int = Depends(get_branch_id),
    current_user: dict = Depends(get_current_user)
):
    print(f"Attempting to create or update setting with key: {setting_in.key} for branch: {branch_id}")
    db_setting = db.query(SystemSetting).filter(
        SystemSetting.key == setting_in.key,
        SystemSetting.branch_id == branch_id
    ).first()
    
    if db_setting:
        print(f"Setting with key {setting_in.key} found, updating.")
        db_setting.value = setting_in.value
        if setting_in.description:
            db_setting.description = setting_in.description
    else:
        print(f"Setting with key {setting_in.key} not found, creating new.")
        db_setting = SystemSetting(
            key=setting_in.key, 
            value=setting_in.value, 
            description=setting_in.description,
            branch_id=branch_id
        )
        db.add(db_setting)
    
    db.commit()
    db.refresh(db_setting)
    return db_setting

@router.get("/{key}", response_model=SettingOut)
def get_setting(
    key: str, 
    db: Session = Depends(get_db), 
    branch_id: int = Depends(get_branch_id),
    current_user: dict = Depends(get_current_user)
):
    setting = db.query(SystemSetting).filter(
        SystemSetting.key == key,
        SystemSetting.branch_id == branch_id
    ).first()
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    return setting
