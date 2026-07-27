import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.schemas.service import AssignedServiceCreate
print("Fields:", list(AssignedServiceCreate.model_fields.keys()))
