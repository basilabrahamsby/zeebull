#!/usr/bin/env python3
import subprocess
import os

auth_content = '''from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import timedelta
from app.database import SessionLocal
from app.schemas.auth import LoginRequest, Token
from app.utils import auth
from app.curd import user as crud_user
from fastapi import Depends
from app.utils.auth import get_current_user


router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=Token)
def login(request: LoginRequest, db: Session = Depends(auth.get_db)):
    try:
        print(f"LOGIN DEBUG: Received email='{request.email}'")
        user = crud_user.get_user_by_email(db, request.email)
        if not user:
            print(f"LOGIN DEBUG: User not found for email: '{request.email}'")
            raise HTTPException(status_code=400, detail="Invalid credentials")
        
        print(f"LOGIN DEBUG: User found: id={user.id}, active={user.is_active}, role={user.role}")
        
        if not user.is_active:
            print(f"Login attempt: User {request.email} is inactive")
            raise HTTPException(status_code=400, detail="Account is inactive. Please contact administrator.")
        
        if not user.role:
            print(f"Login attempt: User {request.email} has no role assigned")
            raise HTTPException(status_code=400, detail="User role not assigned. Please contact administrator.")
        
        try:
            password_valid = auth.verify_password(request.password, user.hashed_password)
        except Exception as pwd_error:
            print(f"Password verification error for {request.email}: {str(pwd_error)}")
            import traceback
            traceback.print_exc()
            raise HTTPException(status_code=400, detail="Invalid credentials")
        
        if not password_valid:
            print(f"Login attempt: Invalid password for email: {request.email}")
            raise HTTPException(status_code=400, detail="Invalid credentials")
        
        from app.models.employee import Employee
        employee = db.query(Employee).filter(Employee.user_id == user.id).first()
        employee_id = employee.id if employee else None
        
        token_data = {"user_id": user.id, "role": user.role.name}
        if employee_id:
            token_data["employee_id"] = employee_id
            
        access_token = auth.create_access_token(
            data=token_data,
            expires_delta=timedelta(hours=auth.ACCESS_TOKEN_EXPIRE_MINUTES),
        )
        print(f"Login successful: {request.email}, employee_id: {employee_id}")
        return {"access_token": access_token, "token_type": "bearer"}
    except HTTPException:
        raise
    except Exception as e:
        print(f"Login error for {request.email}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Login failed: {str(e)}")


@router.get("/admin-only")
def admin_data(user=Depends(get_current_user)):
    if user.role.name != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")
    return {"message": "Admin access granted"}
'''

# Write to temp file
with open('/tmp/auth_fixed.py', 'w') as f:
    f.write(auth_content)

# Upload and restart
subprocess.run([
    'scp', '-i', os.path.expanduser('~/.ssh/gcp_key'),
    '/tmp/auth_fixed.py',
    'basilabrahamaby@136.113.93.47:/tmp/auth_fixed.py'
])

subprocess.run([
    'ssh', '-i', os.path.expanduser('~/.ssh/gcp_key'),
    'basilabrahamaby@136.113.93.47',
    'sudo cp /tmp/auth_fixed.py /var/www/inventory/ResortApp/app/api/auth.py && sudo systemctl restart inventory-resort && sudo systemctl status inventory-resort'
])

print("Done!")
