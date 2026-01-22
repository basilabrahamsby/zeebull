import os
from dotenv import load_dotenv
import subprocess
import sys
from urllib.parse import urlparse

env_path = os.path.join("ResortApp", ".env")
load_dotenv(env_path)
db_url = os.getenv("DATABASE_URL")

if not db_url:
    print("DATABASE_URL not found")
    sys.exit(1)

parsed = urlparse(db_url)
env = os.environ.copy()
if parsed.password:
    env["PGPASSWORD"] = parsed.password

user = parsed.username
host = parsed.hostname
port = str(parsed.port) if parsed.port else "5432"
dbname = parsed.path.lstrip('/')

print(f"Dumping {dbname} from {host} as {user}...")

try:
    cmd = ["pg_dump", "-h", host, "-p", port, "-U", user, "-d", dbname, "-f", "local_backup.sql", "--clean", "--if-exists", "--no-owner", "--no-acl"]
    result = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if result.returncode != 0:
        print("pg_dump failed:")
        print(result.stderr)
    else:
        print("Backup successful: local_backup.sql")
except Exception as e:
    print("Execution failed:", e)
