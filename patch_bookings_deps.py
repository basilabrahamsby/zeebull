import re

with open(r"d:\Zeebull\dasboard\src\pages\Bookings.jsx", "r", encoding="utf-8") as f:
    content = f.read()

# Fix RoomFoodOrders dependency
food_effect = r"(\s*useEffect\(\(\) => \{\s*fetchOrders\(\);\s*\}\, \[booking\]\);)"
new_food_effect = r"\n  useEffect(() => {\n    fetchOrders();\n  }, [booking, selectedRoomIndex]);"
content = re.sub(food_effect, new_food_effect, content)

# Fix RoomServiceAssignments dependency
service_effect = r"(\s*useEffect\(\(\) => \{\s*fetchData\(\);\s*\}\, \[booking\]\);)"
new_service_effect = r"\n  useEffect(() => {\n    fetchData();\n  }, [booking, selectedRoomIndex]);"
content = re.sub(service_effect, new_service_effect, content)


with open(r"d:\Zeebull\dasboard\src\pages\Bookings.jsx", "w", encoding="utf-8") as f:
    f.write(content)

print("Dependencies fixed!")
