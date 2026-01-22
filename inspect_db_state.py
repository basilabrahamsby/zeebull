from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import sys

# Use the credentials that we saw in the logs
DATABASE_URL = "postgresql+psycopg2://orchid_user:admin123@localhost:5432/orchiddb"

def inspect():
    try:
        engine = create_engine(DATABASE_URL)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        
        print(f"Connected to {DATABASE_URL}")
        
        # 1. Check User 1
        user = db.execute(text("SELECT id, email, is_active FROM users WHERE id = 1")).fetchone()
        print(f"User 1: {user}")
        
        if not user:
            print("User 1 missing!")
            return

        # 2. Check Employee 5
        emp = db.execute(text("SELECT id, name, user_id, status FROM employees WHERE id = 5")).fetchone()
        print(f"Employee 5: {emp}")
        
        # 3. Check Who is linked to User 1?
        linked = db.execute(text("SELECT id, name, user_id, status FROM employees WHERE user_id = 1")).fetchall()
        print(f"Employees linked to User 1: {linked}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    inspect()
