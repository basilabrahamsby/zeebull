from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# Load env variables
load_dotenv(dotenv_path="ResortApp/.env")

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    # Fallback/Hardcode if env not picked up correctly in this context
    DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/orchid_db" 

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def check_link():
    db = SessionLocal()
    try:
        # Check User 1
        result = db.execute(text("SELECT id, email, role_id FROM users WHERE id = 1")).fetchone()
        print(f"User 1: {result}")
        if not result:
            print("User 1 not found!")
            return

        # Check Linked Employee
        emp = db.execute(text("SELECT id, name, user_id FROM employees WHERE user_id = 1")).fetchone()
        print(f"Linked Employee for User 1: {emp}")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_link()
