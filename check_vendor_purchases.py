import subprocess
import json

# SSH command to check vendor purchases
cmd = [
    "ssh", "-o", "StrictHostKeyChecking=no",
    "-i", r"C:\Users\pro\.ssh\gcp_key",
    "basilabrahamaby@136.113.93.47",
    "sudo -u postgres psql orchid_resort -t -A -F',' -c \"SELECT v.id, v.name, COUNT(p.id) as purchase_count, COALESCE(SUM(p.total_amount), 0) as total_amount, COALESCE(SUM(p.paid_amount), 0) as paid_amount, COUNT(CASE WHEN p.status = 'received' THEN 1 END) as received_count FROM vendors v LEFT JOIN purchases p ON v.id = p.vendor_id WHERE LOWER(v.name) LIKE '%sharma%' GROUP BY v.id, v.name;\""
]

result = subprocess.run(cmd, capture_output=True, text=True)
print("Output:")
print(result.stdout)
if result.stderr:
    print("Errors:")
    print(result.stderr)
