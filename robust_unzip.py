import zipfile
import sys

def extract_all():
    zip_path = '/tmp/zeebull_backend.zip'
    dest_path = '/var/www/zeebull/ResortApp/'
    print(f"Extracting {zip_path} to {dest_path}")
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(dest_path)
        print("Extraction complete.")
    except Exception as e:
        print(f"Error extracting zip: {e}")
        sys.exit(1)

if __name__ == "__main__":
    extract_all()
