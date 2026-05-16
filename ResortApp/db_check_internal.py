import psycopg2
try:
    conn = psycopg2.connect("postgresql://postgres:qwerty123@localhost:5432/zeebull")
    print("Connection successful")
    cur = conn.cursor()
    cur.execute("SELECT name FROM employees WHERE id = 5")
    row = cur.fetchone()
    if row:
        print(f"Found: {row[0]}")
    else:
        print("Not found")
    conn.close()
except Exception as e:
    print(f"Error: {e}")
