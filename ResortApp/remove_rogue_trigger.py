
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

def cleanup():
    with engine.connect() as conn:
        # Find triggers on users table
        print("Finding triggers on 'users' table...")
        sql = text("""
            SELECT trigger_name 
            FROM information_schema.triggers 
            WHERE event_object_table = 'users'
        """)
        triggers = conn.execute(sql).mappings().all()
        
        for t in triggers:
            name = t['trigger_name']
            print(f"Dropping trigger: {name}")
            conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON users;"))
            conn.commit()
            print(f"✓ Dropped {name}")

        # Find triggers on employees table
        print("\nFinding triggers on 'employees' table...")
        sql = text("""
            SELECT trigger_name 
            FROM information_schema.triggers 
            WHERE event_object_table = 'employees'
        """)
        triggers = conn.execute(sql).mappings().all()
        
        for t in triggers:
            name = t['trigger_name']
            print(f"Dropping trigger: {name}")
            conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON employees;"))
            conn.commit()
            print(f"✓ Dropped {name}")

if __name__ == "__main__":
    cleanup()
