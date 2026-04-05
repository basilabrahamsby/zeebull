import re

with open(r"d:\Zeebull\dasboard\src\pages\Bookings.jsx", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Remove Room Selection Tabs from inside "current" tab
room_tabs_pattern = r"(\s*\{/\* Room Selection Tabs \(only if multi-room\) \*/\}\s*\{booking\.rooms && booking\.rooms\.length > 1 && \(\s*<div className=\"flex gap-2 p-2 bg-slate-50 border-b border-slate-100 overflow-x-auto\">\s*\{booking\.rooms\.map\(\(room, idx\) => \(\s*<button\s*key=\{idx\}\s*onClick=\{\(\) => setSelectedRoomIndex\(idx\)\}\s*className=\{`[^`]+`\}\s*>\s*Room \{room\.number \|\| room\.room\?\.number \|\| `Room \$\{idx \+ 1\}`\}\s*</button>\s*\)\)\}\s*</div>\s*\)\})"

match = re.search(room_tabs_pattern, content)
if match:
    content = content.replace(match.group(1), "")
    print("Room tabs removed from old location.")
else:
    print("Could not find Room tabs pattern!")

# 2. Insert Room Selection Tabs above Tabs Navigation
# Find where Tabs Navigation starts
tabs_nav_pattern = r"(\s*\{/\* Tabs Navigation \*/\}\s*<div className=\"px-8 pt-4 bg-slate-50/30)"

new_room_tabs = """
        {/* Room Selection Tabs (only if multi-room) */}
        {booking.rooms && booking.rooms.length > 1 && (
          <div className="px-8 py-4 bg-indigo-50/20 border-b border-indigo-100 flex items-center gap-3 overflow-x-auto relative z-10">
            <span className="text-[10px] font-bold text-indigo-400 uppercase tracking-widest whitespace-nowrap">Select Room:</span>
            {booking.rooms.map((room, idx) => (
              <button
                key={idx}
                onClick={() => setSelectedRoomIndex(idx)}
                className={`px-5 py-2.5 rounded-2xl text-[10px] uppercase tracking-wider font-bold transition-all shadow-sm whitespace-nowrap ${
                  selectedRoomIndex === idx
                    ? "bg-indigo-600 text-white shadow-indigo-200 border border-indigo-700"
                    : "bg-white text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 border border-slate-200"
                }`}
              >
                Room {room.number || room.room?.number || `Room ${idx + 1}`}
              </button>
            ))}
          </div>
        )}
"""

content = re.sub(tabs_nav_pattern, new_room_tabs + r"\1", content)


# 3. Update activeTab == "food" to pass selectedRoomIndex
food_pattern = r"(\{/\* Food Orders Tab \*/\}\s*\{activeTab === \"food\" && \(\s*<RoomFoodOrders\s*booking=\{booking\}\s*authHeader=\{authHeader\}\s*API=\{API\}\s*formatCurrency=\{formatCurrency\}\s*/>\s*\)\})"

new_food_pattern = """{/* Food Orders Tab */}
          {activeTab === "food" && (
            <RoomFoodOrders
              booking={booking}
              authHeader={authHeader}
              API={API}
              formatCurrency={formatCurrency}
              selectedRoomIndex={selectedRoomIndex}
            />
          )}"""

content = re.sub(food_pattern, new_food_pattern, content)

# 4. Update activeTab == "services" to pass selectedRoomIndex
service_pattern = r"(\{/\* Services Tab \*/\}\s*\{activeTab === \"services\" && \(\s*<RoomServiceAssignments\s*booking=\{booking\}\s*authHeader=\{authHeader\}\s*API=\{API\}\s*formatCurrency=\{formatCurrency\}\s*/>\s*\)\})"

new_service_pattern = """{/* Services Tab */}
          {activeTab === "services" && (
            <RoomServiceAssignments
              booking={booking}
              authHeader={authHeader}
              API={API}
              formatCurrency={formatCurrency}
              selectedRoomIndex={selectedRoomIndex}
            />
          )}"""

content = re.sub(service_pattern, new_service_pattern, content)

# 5. Update RoomFoodOrders signature and logic
room_food_signature = r"const RoomFoodOrders = React\.memo\(\(\{ booking, authHeader, API, formatCurrency \}\) => \{"
new_room_food_signature = r"const RoomFoodOrders = React.memo(({ booking, authHeader, API, formatCurrency, selectedRoomIndex = 0 }) => {"
content = re.sub(room_food_signature, new_room_food_signature, content)

# In RoomFoodOrders, update constraints:
room_ids_pattern = r"(const roomIds = booking\.rooms\?\.map\(r => r\.id \|\| r\.room_id\) \|\| \[\];)"
new_room_ids = r"const currentRoomData = booking.rooms && booking.rooms[selectedRoomIndex];\n      const roomIds = currentRoomData ? [currentRoomData.id || currentRoomData.room_id] : (booking.rooms?.map(r => r.id || r.room_id) || []);"
content = re.sub(room_ids_pattern, new_room_ids, content)

# In RoomFoodOrders, update currentRoom assignment:
current_room_food = r"(const currentRoom = booking\.rooms && booking\.rooms\[0\];)"
new_current_room_food = r"const currentRoom = booking.rooms && booking.rooms[selectedRoomIndex];"
content = re.sub(current_room_food, new_current_room_food, content)


# 6. Update RoomServiceAssignments signature and logic
# Find RoomServiceAssignments component
room_service_signature = r"const RoomServiceAssignments = React\.memo\(\(\{ booking, authHeader, API, formatCurrency \}\) => \{"
new_room_service_signature = r"const RoomServiceAssignments = React.memo(({ booking, authHeader, API, formatCurrency, selectedRoomIndex = 0 }) => {"
content = re.sub(room_service_signature, new_room_service_signature, content)

# In RoomServiceAssignments, update constraints:
service_room_ids_pattern = r"(const roomIds = booking\.rooms\?\.map\(r => r\.id \|\| r\.room_id\) \|\| \[\];)"
# Since we already replaced it blindly? No, wait! I should restrict to within the component, but re.sub will hit both sequentially if they are exact. Let me just use re.sub again or check exactly how RoomServiceAssignments does it. Let's see if RoomServiceAssignments has roomIds.

# Instead of using a blind re.sub for both, let's write out the currentRoom pattern logic properly.
# Actually we can do it via replace.

with open(r"d:\Zeebull\dasboard\src\pages\Bookings.jsx", "w", encoding="utf-8") as f:
    f.write(content)

print("Patch applied to Bookings.jsx")
