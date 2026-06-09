
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

def cleanup():
    with engine.connect() as conn:
        print("--- Starting Final Aggressive Cleanup of Guest Data in Employees ---")
        
        # 1. Target specific users identified as guests but with employee roles
        # Users 41, 42, 43 are known suspects from our check
        suspect_user_ids = [41, 42, 43, 61] 
        print(f"Targeting specific suspect users: {suspect_user_ids}")
        
        # Fix their roles to 'guest' (13)
        sql_fix_users = text("UPDATE users SET role_id = 13 WHERE id = ANY(:ids)")
        conn.execute(sql_fix_users, {"ids": suspect_user_ids})
        conn.commit()
        print("✓ Updated target user roles to 'guest' (13)")

        # 2. Identify and remove ALL employee records linked to users with role 'guest' (13)
        print("\nChecking for employee records linked to 'guest' role users...")
        sql_find_emp = text("""
            SELECT e.id, e.name, u.email, u.id as user_id
            FROM employees e 
            JOIN users u ON e.user_id = u.id 
            WHERE u.role_id = 13
        """)
        guest_emps = conn.execute(sql_find_emp).mappings().all()
        
        if guest_emps:
            print(f"Found {len(guest_emps)} guest records in employees table.")
            for emp in guest_emps:
                print(f"  Removing Employee ID {emp['id']} ({emp['name']}) linked to user {emp['user_id']} ({emp['email']})")
            
            emp_ids = [e['id'] for e in guest_emps]
            sql_del_emp = text("DELETE FROM employees WHERE id = ANY(:ids)")
            conn.execute(sql_del_emp, {"ids": emp_ids})
            conn.commit()
            print("✓ Removed guest records from employees table.")
        else:
            print("No guest records found in employees table for role_id 13.")

        # 3. Final Sweep: Any user with Agoda/Booking/Temp email should be role 13 and NOT in employees
        print("\nPerforming final sweep of all Agoda/Booking/Temp users...")
        
        # Update roles first
        sql_sweep_roles = text("""
            UPDATE users 
            SET role_id = 13 
            WHERE (email LIKE '%agoda-messaging.com' OR email LIKE '%guest.booking.com' OR email LIKE '%@temp.com' OR email LIKE 'guest_%')
            AND role_id != 13
        """)
        res_roles = conn.execute(sql_sweep_roles)
        conn.commit()
        print(f"✓ Updated {res_roles.rowcount} users to 'guest' role based on email patterns.")

        # Delete from employees
        sql_sweep_emps = text("""
            DELETE FROM employees 
            WHERE user_id IN (
                SELECT id FROM users 
                WHERE role_id = 13
            )
        """)
        res_emps = conn.execute(sql_sweep_emps)
        conn.commit()
        print(f"✓ Removed {res_emps.rowcount} additional records from employees table where role is 'guest'.")

if __name__ == "__main__":
    cleanup()
