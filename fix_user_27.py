from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql+psycopg2://orchid_user:admin123@localhost:5432/orchid_resort"

def check_user_27():
    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as conn:
            # Check User 27 - Select only existing columns
            # User model has: id, name, email, role_id. 
            # We skip 'role' column as it is a relationship via role_id.
            user = conn.execute(text("SELECT id, email, name FROM users WHERE id = 27")).fetchone()
            print(f"User 27: {user}")
            
            if user:
                # Check Employee Link - Select existing columns
                emp = conn.execute(text(f"SELECT id, name, user_id FROM employees WHERE user_id = {user[0]}")).fetchone()
                print(f"Linked Employee: {emp}")
                
                if not emp:
                    print("User 27 has NO linked Employee profile. Creating one...")
                    # Create Employee
                    # Based on Employee model: name, role, salary, join_date, image_url, user_id
                    # We assume phone/email/status are NOT in the table or are nullable if they exist in DB but not model.
                    # We'll try to insert minimal fields.
                    query = text("""
                        INSERT INTO employees (name, role, salary, join_date, image_url, user_id)
                        VALUES (:name, :role, 0, '2025-01-01', '', :uid)
                        RETURNING id
                    """)
                    name = user.name or "Housekeeper"
                    role = "Housekeeping" # Hardcoded based on token info
                    
                    new_id = conn.execute(query, {"name": name, "role": role, "uid": user[0]}).fetchone()[0]
                    conn.commit()
                    print(f"FIXED: Created Employee ID {new_id} linked to User 27")
                else:
                    print(f"User 27 ALREADY linked to Employee {emp[0]}")
            else:
                print("User 27 does not exist!")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_user_27()
