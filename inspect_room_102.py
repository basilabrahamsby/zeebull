
import sqlite3
import json

db_path = 'c:/releasing/New Orchid/ResortApp/orchid.db'
conn = sqlite3.connect(db_path)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

cursor.execute("SELECT * FROM checkout_requests WHERE room_number = '102' ORDER BY id DESC LIMIT 1")
row = cursor.fetchone()
if row:
    print(f"Request ID: {row['id']}")
    print(f"Status: {row['status']}")
    print(f"Inventory Checked: {row['inventory_checked']}")
    if row['inventory_data']:
        data = json.loads(row['inventory_data'])
        print("Inventory Data JSON:")
        print(json.dumps(data, indent=2))
else:
    print("No checkout request found for room 102")

conn.close()
