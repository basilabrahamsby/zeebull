from app.database import SessionLocal
from sqlalchemy import text
from app.utils import auth

db = SessionLocal()
try:
    email = 'roomservice@gmail.com'
    password = 'op123'
    
    # Check if user exists
    result = db.execute(text("SELECT id FROM users WHERE email = :e"), {"e": email})
    user_row = result.fetchone()
    
    if not user_row:
        print(f"User {email} does not exist. Creating...")
        # Get first branch and first role
        branch_res = db.execute(text("SELECT id FROM branches LIMIT 1"))
        branch_id = branch_res.fetchone()[0]
        role_res = db.execute(text("SELECT id FROM roles LIMIT 1"))
        role_id = role_res.fetchone()[0]
        
        hashed = auth.get_password_hash(password)
        db.execute(text("""
            INSERT INTO users (email, hashed_password, is_active, role_id, branch_id, created_at, updated_at)
            VALUES (:e, :h, TRUE, :r, :b, NOW(), NOW())
        """), {"e": email, "h": hashed, "r": role_id, "b": branch_id})
        print(f"User {email} created with password {password}")
    else:
        print(f"User {email} exists. Updating password and status...")
        hashed = auth.get_password_hash(password)
        db.execute(text("UPDATE users SET hashed_password = :h, is_active = TRUE WHERE email = :e"), {"h": hashed, "e": email})
        
        # Ensure role is assigned
        res = db.execute(text("SELECT role_id FROM users WHERE email = :e"), {"e": email})
        if not res.fetchone()[0]:
            role_res = db.execute(text("SELECT id FROM roles LIMIT 1"))
            role_id = role_res.fetchone()[0]
            db.execute(text("UPDATE users SET role_id = :r WHERE email = :e"), {"r": role_id, "e": email})
            print(f"Assigned role {role_id} to {email}")
            
    db.commit()
    print(f"User {email} is ready for login.")
except Exception as e:
    db.rollback()
    print(f"Error: {e}")
finally:
    db.close()
