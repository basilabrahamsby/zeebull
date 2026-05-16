
from app.utils.auth import get_db
from app.models.inventory import StockIssue, StockIssueDetail, InventoryItem
from app.models.room import Room
from datetime import datetime, timedelta

db = next(get_db())

# Get room and item
room = db.query(Room).filter(Room.number == "502").first()
item = db.query(InventoryItem).filter(InventoryItem.name == "Coke").first()

if not item:
    # Create item if missing
    from app.models.inventory import InventoryCategory
    cat = db.query(InventoryCategory).first()
    item = InventoryItem(name="Coke", category_id=cat.id, branch_id=1, unit="can", selling_price=50.0, is_active=True)
    db.add(item)
    db.commit()
    db.refresh(item)

# Create StockIssue
issue = StockIssue(
    issue_number="SI-DEBUG-001",
    destination_location_id=room.inventory_location_id,
    issue_date=datetime.now(),
    notes="Test issue for billing",
    branch_id=1,
    issued_by=1 # System
)
db.add(issue)
db.commit()
db.refresh(issue)

# Create Detail
detail = StockIssueDetail(
    issue_id=issue.id,
    item_id=item.id,
    issued_quantity=2,
    unit="can",
    is_payable=True
)
db.add(detail)
db.commit()

print(f"Created StockIssue {issue.issue_number} with {detail.issued_quantity} {item.name}")
