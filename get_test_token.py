from app.database import SessionLocal
from app.models.user import User
from app.utils.auth import create_access_token

db = SessionLocal()
u = db.query(User).first()
if u:
    token = create_access_token(data={"sub": u.email})
    print(token)
else:
    print("No user found")
