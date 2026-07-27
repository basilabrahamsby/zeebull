import sys
from sqlalchemy import MetaData, text
from app.database import engine, SessionLocal

def main():
    metadata = MetaData()
    metadata.reflect(bind=engine)
    db = SessionLocal()
    try:
        print("=== DATABASE TABLE ROW COUNTS ===")
        for table_name in sorted(metadata.tables.keys()):
            # Get row count
            try:
                count = db.execute(text(f"SELECT COUNT(*) FROM \"{table_name}\"")).scalar()
                print(f"Table '{table_name}': {count} rows")
            except Exception as e:
                print(f"Table '{table_name}': Error {e}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
    finally:
        db.close()

if __name__ == "__main__":
    main()
