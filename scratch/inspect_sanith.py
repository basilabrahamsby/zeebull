import sys
sys.path.append('/var/www/zeebull/ResortApp')
from app.database import SessionLocal
from app.models.user import User
db = SessionLocal()
u = db.query(User).filter(User.id == 33).first()
if u:
    old_name = u.name
    u.name = "Sanith"
    db.commit()
    print(f"Successfully changed User 33 name from '{old_name}' to 'Sanith'")
else:
    print("User 33 not found")
