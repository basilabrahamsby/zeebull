from app.models import *
from app.database import Base, engine
try:
    from sqlalchemy.orm import configure_mappers
    configure_mappers()
    print("Mappers configured successfully")
except Exception as e:
    import traceback
    traceback.print_exc()
