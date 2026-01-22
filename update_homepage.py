import json
import sys

def update_homepage(file_path, new_homepage):
    with open(file_path, 'r') as f:
        data = json.load(f)
    data['homepage'] = new_homepage
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    update_homepage(sys.argv[1], sys.argv[2])
