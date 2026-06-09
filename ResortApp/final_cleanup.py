
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

def cleanup():
    with engine.connect() as conn:
        print("--- Starting Final Cleanup of Guest Data in Employees ---")
        
        # 1. Identify users that look like guests but have non-guest roles
        # We'll target users with agoda or booking.com emails that are NOT role 13 (guest)
        print("Identifying guests with incorrect roles...")
        sql = text("""
            SELECT id, email, role_id 
            FROM users 
            WHERE (email LIKE '%agoda-messaging.com' OR email LIKE '%guest.booking.com')
            AND role_id != 13
        """)
        misplaced_users = conn.execute(sql).mappings().all()
        user_ids = [u['id'] for u in misplaced_users]
        
        if user_ids:
            print(f"Found {len(user_ids)} guests with incorrect roles: {user_ids}")
            # Fix their roles to 'guest' (13)
            sql_fix_users = text("UPDATE users SET role_id = 13 WHERE id = ANY(:ids)")
            conn.execute(sql_fix_users, {"ids": user_ids})
            conn.commit()
            print("✓ Updated user roles to 'guest' (13)")

        # 2. Identify and remove any employee records linked to 'guest' role users
        print("\nChecking for employee records linked to guests...")
        sql_find_emp = text("""
            SELECT e.id, e.name, u.email 
            FROM employees e 
            JOIN users u ON e.user_id = u.id 
            WHERE u.role_id = 13
        """)
        guest_emps = conn.execute(sql_find_emp).mappings().all()
        
        if guest_emps:
            print(f"Found {len(guest_emps)} guest records in employees table.")
            for emp in guest_emps:
                print(f"  Removing Employee ID {emp['id']} ({emp['name']}) linked to guest {emp['email']}")
            
            emp_ids = [e['id'] for e in guest_emps]
            sql_del_emp = text("DELETE FROM employees WHERE id = ANY(:ids)")
            conn.execute(sql_del_emp, {"ids": emp_ids})
            conn.commit()
            print("✓ Removed guest records from employees table.")
        else:
            print("No guest records found in employees table.")

        # 3. Final check for any email-based guests in employees
        print("\nPerforming final email-based sweep...")
        sql_sweep = text("""
            DELETE FROM employees 
            WHERE user_id IN (
                SELECT id FROM users 
                WHERE email LIKE 'guest_%' OR email LIKE '%@temp.com'
                OR email LIKE '%agoda-messaging.com' OR email LIKE '%guest.booking.com'
            )
        """)
        res = conn.execute(sql_sweep)
        conn.commit()
        print(f"✓ Swept {res.rowcount} additional records from employees table.")

if __name__ == "__main__":
    cleanup()
