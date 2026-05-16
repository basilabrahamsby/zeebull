from app.database import SessionLocal
from sqlalchemy import text

db = SessionLocal()
try:
    # Set user to active
    db.execute(text("UPDATE users SET is_active = TRUE WHERE email = 'op@gmail.com'"))
    
    # Check if user has a role_id
    result = db.execute(text("SELECT role_id FROM users WHERE email = 'op@gmail.com'"))
    role_id = result.fetchone()[0]
    
    if not role_id:
        # Assign first available role
        role_result = db.execute(text("SELECT id FROM roles LIMIT 1"))
        first_role = role_result.fetchone()
        if first_role:
            db.execute(text("UPDATE users SET role_id = :r WHERE email = 'op@gmail.com'"), {"r": first_role[0]})
            print(f"Assigned role {first_role[0]} to op@gmail.com")
        else:
            print("No roles found in database!")
    else:
        print(f"User already has role {role_id}")
        
    db.commit()
    print("User op@gmail.com is now active and has a role.")
except Exception as e:
    db.rollback()
    print(f"Error: {e}")
finally:
    db.close()
