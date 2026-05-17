with open(r'd:\Zeebull\ResortApp\app\api\checkout.py', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

print("Searching for checkout-request in app/api/checkout.py:")
for idx, line in enumerate(lines):
    if 'checkout-request' in line.lower() or 'exists' in line.lower() or 'checkout_request' in line.lower():
        if any(term in line.lower() for term in ['def ', 'router.', 'exists']):
            print(f"Line {idx+1}: {line.strip()}")
