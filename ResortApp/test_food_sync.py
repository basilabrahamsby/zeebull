from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.curd.foodorder import create_food_order, sync_food_order_to_requests, update_food_order_status
from app.models.foodorder import FoodOrder, FoodOrderItem
from app.models.service_request import ServiceRequest
from app.schemas.foodorder import FoodOrderCreate, FoodOrderItemCreate
from app.models.room import Room
from app.models.food_item import FoodItem

def test_sync():
    db = SessionLocal()
    try:
        # Find or create a room
        room = db.query(Room).first()
        if not room:
            room = Room(number="999", type="Deluxe", branch_id=1, status="available", price=1000.0)
            db.add(room)
            db.commit()
            db.refresh(room)
            print(f"Created temporary room {room.id} ({room.number})")
        else:
            print(f"Using existing room {room.id} ({room.number})")

        # Find or create a food item
        food_item = db.query(FoodItem).first()
        if not food_item:
            food_item = FoodItem(name="Temp Burger", price=100.0, branch_id=1, category_id=1)
            db.add(food_item)
            db.commit()
            db.refresh(food_item)
            print(f"Created temporary food item {food_item.id} ({food_item.name})")
        else:
            print(f"Using existing food item {food_item.id} ({food_item.name})")

        # 1. Create a food order with room service
        order_in = FoodOrderCreate(
            room_id=room.id,
            order_type="room_service",
            items=[FoodOrderItemCreate(food_item_id=food_item.id, quantity=1)],
            amount=100.0,
            branch_id=1
        )
        order = create_food_order(db, order_in, branch_id=1)
        print(f"Created order {order.id}")
        
        # 2. Check service requests
        requests = db.query(ServiceRequest).filter(ServiceRequest.food_order_id == order.id).all()
        print(f"Initial requests: {[(r.request_type, r.status) for r in requests]}")
        assert len(requests) > 0, "No ServiceRequest was created for room service order!"
        assert requests[0].request_type == "room_service", f"Expected request_type 'room_service', got '{requests[0].request_type}'"
        
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

        # Cleanup created food order
        db.query(FoodOrderItem).filter(FoodOrderItem.order_id == order.id).delete()
        db.query(ServiceRequest).filter(ServiceRequest.food_order_id == order.id).delete()
        db.query(FoodOrder).filter(FoodOrder.id == order.id).delete()
        db.commit()
        print("Cleaned up food order and requests successfully!")

    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()

if __name__ == "__main__":
    test_sync()
