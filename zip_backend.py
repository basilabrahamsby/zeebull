import zipfile, os
def zip_folder(folder_path, output_path):
    print(f"Zipping {folder_path} to {output_path}...")
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            # Exclude directories
            dirs[:] = [d for d in dirs if d not in ['venv', '__pycache__', '.git', '.idea', '.vscode']]
            
            for file in files:
                if file.endswith('.pyc') or file == '.env': 
                    continue
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, folder_path)
                zipf.write(file_path, arcname)
    print("Done.")

if __name__ == "__main__":
    zip_folder('ResortApp', 'backend_clean.zip')
