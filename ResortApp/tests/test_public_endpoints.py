import pytest
from app.models.room import Room
from app.models.food_item import FoodItem
from app.models.food_category import FoodCategory

class TestPublicEndpoints:
    def test_get_public_branches(self, client, test_branch, db_session):
        test_branch.is_active = True
        db_session.add(test_branch)
        db_session.flush()

        response = client.get("/api/public/branches")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert any(b["id"] == test_branch.id for b in data)

    def test_get_public_rooms(self, client, test_branch, db_session):
        room = Room(number="R-PUBLIC-101", branch_id=test_branch.id, status="Available")
        db_session.add(room)
        db_session.flush()

        response = client.get(f"/api/public/rooms?branch_id={test_branch.id}")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert any(r["number"] == "R-PUBLIC-101" for r in data)

    def test_get_public_food_items_and_categories(self, client, test_branch, db_session):
        cat = FoodCategory(name="Public Snacks", branch_id=test_branch.id)
        db_session.add(cat)
        db_session.flush()

        item = FoodItem(
            name="Public Tea",
            price=20.0,
            room_service_price=25.0,
            available=True,
            always_available=True,
            category_id=cat.id,
            branch_id=test_branch.id
        )
        db_session.add(item)
        db_session.flush()

        # Test categories
        response = client.get("/api/public/food-categories")
        assert response.status_code == 200
        assert any(c["id"] == cat.id for c in response.json())

        # Test food items
        response = client.get(f"/api/public/food-items?branch_id={test_branch.id}")
        assert response.status_code == 200
        assert any(f["id"] == item.id for f in response.json())

    def test_post_public_food_order(self, client, test_branch, db_session):
        room = Room(number="R-PUBLIC-102", branch_id=test_branch.id, status="Available")
        db_session.add(room)
        
        cat = FoodCategory(name="Public Snacks", branch_id=test_branch.id)
        db_session.add(cat)
        db_session.flush()

        item = FoodItem(
            name="Public Coffee",
            price=30.0,
            available=True,
            always_available=True,
            category_id=cat.id,
            branch_id=test_branch.id
        )
        db_session.add(item)
        db_session.flush()

        payload = {
            "room_id": room.id,
            "amount": 30.0,
            "order_type": "room_service",
            "delivery_request": "Fast please",
            "items": [{"food_item_id": item.id, "quantity": 1}]
        }

        response = client.post("/api/public/food-orders", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["room_id"] == room.id
        assert data["amount"] == 30.0
        assert len(data["items"]) == 1
        assert data["items"][0]["food_item_id"] == item.id

    def test_post_public_service_request(self, client, test_branch, db_session):
        room = Room(number="R-PUBLIC-103", branch_id=test_branch.id, status="Available")
        db_session.add(room)
        db_session.flush()

        payload = {
            "room_id": room.id,
            "request_type": "cleaning",
            "description": "Clean the floor"
        }

        response = client.post("/api/public/service-requests", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["room_id"] == room.id
        assert data["request_type"] == "cleaning"
        assert data["description"] == "Clean the floor"
