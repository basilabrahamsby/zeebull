import subprocess

# SQL command to fix the purchase order - use correct table name and columns
sql_cmd = "UPDATE purchase_masters SET sub_total = 2000.00, cgst = 180.00, sgst = 180.00, total_amount = 2360.00, payment_status = 'paid' WHERE purchase_number = 'PO-20260111-0001'; SELECT purchase_number, total_amount, payment_status FROM purchase_masters WHERE purchase_number = 'PO-20260111-0001';"

# Execute via SSH
cmd = [
    "ssh", "-o", "StrictHostKeyChecking=no",
    "-i", r"C:\Users\pro\.ssh\gcp_key",
    "basilabrahamaby@136.113.93.47",
    f"sudo -u postgres psql -d orchid_resort -c \"{sql_cmd}\""
]

result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
print("STDOUT:")
print(result.stdout)
if result.stderr:
    print("\nSTDERR:")
    print(result.stderr)
print(f"\nExit code: {result.returncode}")

