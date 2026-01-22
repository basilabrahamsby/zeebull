from sqlalchemy import create_engine, text
import sys

# Candidates based on findings
URLS = [
    "postgresql://orchid_user:admin123@127.0.0.1:5432/orchid_resort",
    "postgresql://orchid_user:admin123@localhost:5432/orchid_resort",
    "postgresql://orchid_user:admin123@127.0.0.1:5432/orchiddb",
    "postgresql://postgres:qwerty123@127.0.0.1:5432/orchiddb",
    "postgresql://postgres:postgres@127.0.0.1:5432/orchiddb"
]

def check():
    for url in URLS:
        try:
            print(f"Testing: {url} ...")
            engine = create_engine(url)
            with engine.connect() as conn:
                res = conn.execute(text("SELECT current_user, current_database()")).fetchone()
                print(f"SUCCESS! Connected as {res[0]} to {res[1]}")
                return # Stop on first success
        except Exception as e:
            print(f"Failed: {e}")

if __name__ == "__main__":
    check()
