from dotenv import load_dotenv
import os
from pathlib import Path

# Load .env explicitly
env_path = Path(".env")
load_dotenv(dotenv_path=env_path)

from app.database import SessionLocal
from app.models.room import RoomType
from app.core.aiosell_triggers import trigger_rates_push
import logging

# Set up logging to console
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("force_sync")

def force_sync_all():
    db = SessionLocal()
    try:
        room_types = db.query(RoomType).filter(
            RoomType.channel_manager_id.isnot(None),
            RoomType.channel_manager_id != ""
        ).all()

        if not room_types:
            logger.info("No room types with CM mapping found.")
            return

        logger.info(f"Starting force sync for {len(room_types)} room types...")
        for rt in room_types:
            try:
                logger.info(f"Syncing {rt.name} (ID: {rt.id})...")
                # Push for 180 days to be safe
                trigger_rates_push(rt.id, days=180)
            except Exception as e:
                logger.error(f"Failed to sync {rt.name}: {e}")
        
        logger.info("Force sync completed.")
    finally:
        db.close()

if __name__ == "__main__":
    force_sync_all()
