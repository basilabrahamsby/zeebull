#!/usr/bin/env python3
"""Test delete employee REST API endpoint to verify response serialization succeeds with 200 OK."""

import os
import sys
import requests

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User, Role
from app.models.employee import Employee
from app.utils.auth import create_access_token
from sqlalchemy import text

def run_test():
    db = SessionLocal()
    try:
        print("=== TESTING DELETE EMPLOYEE REST API ===")
        
        # 1. Get or create an admin user for authentication
        admin_role = db.query(Role).filter(Role.name == 'admin').first()
        if not admin_role:
            print("ERROR: Admin role not found")
            return
        
        admin_user = db.query(User).filter(User.role_id == admin_role.id).first()
        if not admin_user:
            print("ERROR: Admin user not found")
            return
            
        token = create_access_token(data={'user_id': admin_user.id, 'sub': admin_user.email})
        
        # 2. Get first branch ID
        branch_res = db.execute(text("SELECT id FROM branches LIMIT 1")).first()
        branch_id = branch_res[0] if branch_res else 1
        
        # 3. Create dummy employee to delete
        test_user = User(
            name="API Test Dummy",
            email="apitest@dummy.com",
            hashed_password="dummy",
            role_id=admin_role.id,
            is_active=True
        )
        db.add(test_user)
        db.flush()
        
        test_employee = Employee(
            name="API Test Dummy",
            role="Manager",
            salary=12345.67,
            user_id=test_user.id,
            branch_id=branch_id
        )
        db.add(test_employee)
        db.commit()
        
        employee_id = test_employee.id
        print(f"Created API Test Employee with ID: {employee_id}")
        
        # 4. Make DELETE request
        headers = {
            "Authorization": f"Bearer {token}",
            "X-Branch-Id": str(branch_id)
        }
        url = f"http://localhost:8011/api/employees/{employee_id}"
        
        print(f"Sending DELETE request to {url}...")
        response = requests.delete(url, headers=headers)
        
        print(f"Response Status Code: {response.status_code}")
        print(f"Response JSON: {response.json()}")
        
        assert response.status_code == 200, f"Expected 200, got {response.status_code}"
        json_data = response.json()
        assert json_data.get("message") == "Employee deleted successfully"
        assert json_data.get("employee") is not None
        assert json_data["employee"]["name"] == "API Test Dummy"
        print("SUCCESS: Endpoint serialized successfully and returned 200 OK!")
        
    except Exception as e:
        print(f"ERROR: Test failed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        # Clean up
        try:
            dummy_emp = db.query(Employee).filter(Employee.name == "API Test Dummy").first()
            if dummy_emp:
                db.delete(dummy_emp)
            dummy_user = db.query(User).filter(User.name == "API Test Dummy").first()
            if dummy_user:
                db.delete(dummy_user)
            db.commit()
        except Exception as cleanup_err:
            print(f"Cleanup error: {cleanup_err}")
        db.close()

if __name__ == "__main__":
    run_test()
