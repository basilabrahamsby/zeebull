import sys
import io
import requests

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE_URL = "http://localhost:8011"
EMAIL = "admin@orchid.com"
PASSWORD = "admin123"

ITEMS = [
    {"name": "Mineral Water (1L)",      "unit": "bottles", "unit_price": 20.0,  "min_stock": 50,  "gst": 12.0, "hint": "beverage"},
    {"name": "Soft Drinks (Can)",        "unit": "cans",    "unit_price": 40.0,  "min_stock": 30,  "gst": 12.0, "hint": "beverage"},
    {"name": "Orange Juice (1L)",        "unit": "bottles", "unit_price": 80.0,  "min_stock": 20,  "gst": 12.0, "hint": "beverage"},
    {"name": "Basmati Rice (kg)",        "unit": "kg",      "unit_price": 70.0,  "min_stock": 20,  "gst": 5.0,  "hint": "food"},
    {"name": "Cooking Oil (1L)",         "unit": "litres",  "unit_price": 120.0, "min_stock": 10,  "gst": 5.0,  "hint": "food"},
    {"name": "Sugar (kg)",               "unit": "kg",      "unit_price": 42.0,  "min_stock": 10,  "gst": 5.0,  "hint": "food"},
    {"name": "Salt (kg)",                "unit": "kg",      "unit_price": 20.0,  "min_stock": 5,   "gst": 0.0,  "hint": "food"},
    {"name": "Bread Loaf",              "unit": "pcs",     "unit_price": 35.0,  "min_stock": 10,  "gst": 0.0,  "hint": "food",         "perishable": True},
    {"name": "Eggs (tray/30)",          "unit": "trays",   "unit_price": 150.0, "min_stock": 5,   "gst": 0.0,  "hint": "food",         "perishable": True},
    {"name": "Milk (1L)",               "unit": "litres",  "unit_price": 55.0,  "min_stock": 10,  "gst": 5.0,  "hint": "food",         "perishable": True},
    {"name": "Toilet Soap (bar)",       "unit": "pcs",     "unit_price": 25.0,  "min_stock": 50,  "gst": 18.0, "hint": "housekeeping"},
    {"name": "Shampoo Sachet",          "unit": "pcs",     "unit_price": 10.0,  "min_stock": 100, "gst": 18.0, "hint": "housekeeping"},
    {"name": "Toilet Paper Roll",       "unit": "rolls",   "unit_price": 15.0,  "min_stock": 100, "gst": 18.0, "hint": "housekeeping"},
    {"name": "Bed Sheet (King)",        "unit": "pcs",     "unit_price": 400.0, "min_stock": 20,  "gst": 5.0,  "hint": "housekeeping", "laundry": True},
    {"name": "Pillow Cover",            "unit": "pcs",     "unit_price": 80.0,  "min_stock": 40,  "gst": 5.0,  "hint": "housekeeping", "laundry": True},
    {"name": "Bath Towel",              "unit": "pcs",     "unit_price": 150.0, "min_stock": 30,  "gst": 5.0,  "hint": "housekeeping", "laundry": True},
    {"name": "Hand Towel",              "unit": "pcs",     "unit_price": 80.0,  "min_stock": 30,  "gst": 5.0,  "hint": "housekeeping", "laundry": True},
    {"name": "Floor Cleaner (500ml)",   "unit": "bottles", "unit_price": 90.0,  "min_stock": 10,  "gst": 18.0, "hint": "housekeeping"},
    {"name": "Room Freshener Spray",    "unit": "pcs",     "unit_price": 120.0, "min_stock": 10,  "gst": 18.0, "hint": "housekeeping"},
    {"name": "Notepad (A5)",            "unit": "pcs",     "unit_price": 15.0,  "min_stock": 50,  "gst": 12.0, "hint": "stationery"},
    {"name": "Ballpoint Pen",           "unit": "pcs",     "unit_price": 5.0,   "min_stock": 100, "gst": 12.0, "hint": "stationery"},
    {"name": "Detergent Powder (1kg)",  "unit": "kg",      "unit_price": 80.0,  "min_stock": 10,  "gst": 18.0, "hint": "laundry"},
    {"name": "Fabric Softener (1L)",    "unit": "litres",  "unit_price": 120.0, "min_stock": 5,   "gst": 18.0, "hint": "laundry"},
    {"name": "LED Bulb (9W)",           "unit": "pcs",     "unit_price": 80.0,  "min_stock": 20,  "gst": 18.0, "hint": "maintenance"},
    {"name": "Electrical Tape",         "unit": "rolls",   "unit_price": 30.0,  "min_stock": 10,  "gst": 18.0, "hint": "maintenance"},
    {"name": "WD-40 Spray (300ml)",     "unit": "pcs",     "unit_price": 200.0, "min_stock": 5,   "gst": 18.0, "hint": "maintenance"},
]

# --- Login ---
print("Logging in...")
r = requests.post(
    BASE_URL + "/auth/login",
    json={"email": EMAIL, "password": PASSWORD},
    headers={"Content-Type": "application/json"}
)
if r.status_code != 200:
    print("LOGIN FAILED:", r.status_code, r.text)
    sys.exit(1)
token = r.json()["access_token"]
headers = {"Authorization": "Bearer " + token}
print("Login OK")

# --- Fetch Categories ---
print("Fetching categories...")
r = requests.get(BASE_URL + "/inventory/categories?limit=200&active_only=false", headers=headers)
cats = r.json() if r.status_code == 200 else []
print("Found", len(cats), "categories:")
for c in cats:
    print("  [" + str(c["id"]) + "]", c["name"], "-", c.get("classification", ""))

# Create default category if none exist
if not cats:
    print("No categories found. Creating General category...")
    r = requests.post(
        BASE_URL + "/inventory/categories",
        headers={**headers, "Content-Type": "application/json"},
        json={"name": "General", "description": "General items", "classification": "consumable"}
    )
    if r.status_code in (200, 201):
        cats = [r.json()]
        print("Created General category, ID:", cats[0]["id"])
    else:
        print("Failed to create category:", r.text)
        sys.exit(1)


def find_cat_id(hint):
    h = hint.lower()
    for c in cats:
        if h in c["name"].lower():
            return c["id"]
    for c in cats:
        if h in (c.get("classification") or "").lower():
            return c["id"]
    for c in cats:
        if h in (c.get("parent_department") or "").lower():
            return c["id"]
    return cats[0]["id"]


# --- Create Items ---
print("\nCreating", len(ITEMS), "items...\n")
ok = 0
skip = 0
fail = 0

for item in ITEMS:
    cat_id = find_cat_id(item["hint"])
    form = {
        "name":               (None, item["name"]),
        "unit":               (None, item.get("unit", "pcs")),
        "unit_price":         (None, str(item.get("unit_price", 0))),
        "min_stock_level":    (None, str(item.get("min_stock", 0))),
        "gst_rate":           (None, str(item.get("gst", 0))),
        "category_id":        (None, str(cat_id)),
        "initial_stock":      (None, "0"),
        "is_perishable":      (None, str(item.get("perishable", False)).lower()),
        "track_laundry_cycle":(None, str(item.get("laundry", False)).lower()),
        "is_sellable_to_guest":(None, "false"),
        "is_asset_fixed":     (None, "false"),
        "is_active":          (None, "true"),
    }
    resp = requests.post(BASE_URL + "/inventory/items", headers=headers, files=form)

    if resp.status_code in (200, 201):
        d = resp.json()
        ok += 1
        print("  OK  [" + str(d["id"]) + "] " + d["name"] + " | Rs." + str(d["unit_price"]) + " | cat:" + str(cat_id))
    elif "already exists" in resp.text.lower():
        skip += 1
        print("  SKIP (exists): " + item["name"])
    else:
        fail += 1
        print("  FAIL: " + item["name"] + " -> " + str(resp.status_code) + ": " + resp.text[:120])

print("\n=== DONE ===")
print("Created:", ok, "| Skipped:", skip, "| Failed:", fail)
print("View at: http://localhost:3000/zeebulladmin/inventory")
