from app.database import SessionLocal
from app.utils import auth
from sqlalchemy import text

db = SessionLocal()
try:
    password = "op123"
    hashed = auth.get_password_hash(password)
    db.execute(text("UPDATE users SET hashed_password = :h WHERE email = 'op@gmail.com'"), {"h": hashed})
    db.commit()
    print("Password updated for op@gmail.com to op123")
except Exception as e:
    db.rollback()
    print(f"Error: {e}")
finally:
    db.close()
