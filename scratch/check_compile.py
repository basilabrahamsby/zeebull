import py_compile
import sys

try:
    py_compile.compile(r"c:\releasing\New Orchid\ResortApp\app\api\checkout.py", doraise=True)
    print("Success: app/api/checkout.py has no syntax errors!")
except Exception as e:
    print(f"Error compiling app/api/checkout.py: {e}")
    sys.exit(1)
