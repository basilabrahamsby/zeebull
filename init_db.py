#!/usr/bin/env python3
import sys
sys.path.insert(0, '/var/www/inventory/ResortApp')

from app.database import Base, engine
from app.models import *  # Import all models

print("Creating database tables...")
Base.metadata.create_all(bind=engine)
print("Database tables created successfully!")
