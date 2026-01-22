import zipfile
import os
import shutil

def extract_zip(zip_path, extract_to):
    print(f"Extracting {zip_path} to {extract_to}...")
    
    # Clean output directory
    if os.path.exists(extract_to):
        shutil.rmtree(extract_to)
    os.makedirs(extract_to)
    
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        for file_info in zip_ref.infolist():
            # Fix path separators (convert backslash to forward slash)
            extract_path = file_info.filename.replace('\\', '/')
            
            # Construct full destination path
            destination = os.path.join(extract_to, extract_path)
            
            # Ensure directory exists
            destination_dir = os.path.dirname(destination)
            os.makedirs(destination_dir, exist_ok=True)
            
            # Extract file
            if not file_info.is_dir():
                with zip_ref.open(file_info) as source, open(destination, "wb") as target:
                    shutil.copyfileobj(source, target)
                print(f"Extracted: {destination}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) >= 3:
        zip_path = sys.argv[1]
        extract_to = sys.argv[2]
        extract_zip(zip_path, extract_to)
    else:
        # Fallback / Default behavior
        print("Usage: python3 extract_fixed.py <zip_path> <output_dir>")
        
        # Default behavior for legacy calls (if any)
        REPO_DIR = os.path.expanduser("~/orchid-repo")
        
        # Dashboard
        DASHBOARD_ZIP = os.path.join(REPO_DIR, "dashboard_deploy.zip")
        DASHBOARD_BUILD = os.path.join(REPO_DIR, "dashboard_build")
        if os.path.exists(DASHBOARD_ZIP):
            extract_zip(DASHBOARD_ZIP, DASHBOARD_BUILD)
            
        # Userend
        USEREND_ZIP = os.path.join(REPO_DIR, "userend_deploy.zip")
        USEREND_BUILD = os.path.join(REPO_DIR, "userend_build")
        if os.path.exists(USEREND_ZIP):
            extract_zip(USEREND_ZIP, USEREND_BUILD)
