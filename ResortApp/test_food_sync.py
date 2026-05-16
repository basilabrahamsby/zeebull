
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.curd.foodorder import create_food_order, sync_food_order_to_requests, update_food_order_status
from app.models.foodorder import FoodOrder
from app.models.service_request import ServiceRequest
from app.schemas.foodorder import FoodOrderCreate, FoodOrderItemCreate

def test_sync():
    db = SessionLocal()
    try:
        # 1. Create a food order with room service
        order_in = FoodOrderCreate(
            room_id=1,
            order_type="room_service",
            items=[FoodOrderItemCreate(food_item_id=1, quantity=1)],
            amount=100.0,
            branch_id=1
        )
        order = create_food_order(db, order_in, branch_id=1)
        print(f"Created order {order.id}")
        
        # 2. Check service requests
        requests = db.query(ServiceRequest).filter(ServiceRequest.food_order_id == order.id).all()
        print(f"Initial requests: {[(r.request_type, r.status) for r in requests]}")
        
        # 3. Update food order status to 'cooking'
        print("Updating status to 'cooking'...")
        update_food_order_status(db, order.id, "cooking", branch_id=1)
        
        # 4. Check service requests again
        requests = db.query(ServiceRequest).filter(ServiceRequest.food_order_id == order.id).all()
        print(f"After 'cooking' update: {[(r.request_type, r.status) for r in requests]}")
        
        # 5. Update food order status to 'ready'
        print("Updating status to 'ready'...")
        update_food_order_status(db, order.id, "ready", branch_id=1)
        
        # 6. Check service requests again
        requests = db.query(ServiceRequest).filter(ServiceRequest.food_order_id == order.id).all()
        print(f"After 'ready' update: {[(r.request_type, r.status) for r in requests]}")

    finally:
        db.close()

if __name__ == "__main__":
    test_sync()
