import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import engine
from sqlalchemy import inspect

inspector = inspect(engine)
columns = inspector.get_columns('assigned_services')
for c in columns:
    print(f"Column: {c['name']}, Type: {c['type']}, Nullable: {c['nullable']}")
