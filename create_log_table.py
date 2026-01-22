
import sys
sys.path.append('/var/www/inventory/ResortApp')
from app.database import engine, Base
from app.models.activity_log import ActivityLog

if __name__ == "__main__":
    print("Creating activity_logs table...")
    Base.metadata.create_all(bind=engine)
    print("Done.")
