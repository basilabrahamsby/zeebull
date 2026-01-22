import sys
with open("/etc/nginx/sites-enabled/pomma", "r") as f:
    content = f.read()

start_api = content.find("location /inventoryapi/")
if start_api != -1:
    end_api = content.find("}", start_api) + 1
    print("--- INVENTORYAPI BLOCK ---")
    print(content[start_api:end_api])

start_inv = content.find("location /inventory/")
if start_inv != -1:
    end_inv = content.find("}", start_inv) + 1
    print("\n--- INVENTORY BLOCK ---")
    print(content[start_inv:end_inv])
