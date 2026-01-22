import sys
import os
sys.path.append(os.getcwd())
from app.main import app
for r in app.routes: print(r.path)
