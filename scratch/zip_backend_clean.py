import os
import zipfile

def create_clean_zip(dir_path, output_zip_path):
    excluded_dirs = {'venv', 'uploads', 'uploads_backup_20260414_171324', 'uploads_backup_20260506_234556', 'uploads_old', '.pytest_cache', '__pycache__'}
    excluded_extensions = {'.zip', '.backup', '.dump', '.log'}
    
    with zipfile.ZipFile(output_zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        file_count = 0
        total_size = 0
        for root, dirs, files in os.walk(dir_path):
            dirs[:] = [d for d in dirs if d not in excluded_dirs]
            
            for file in files:
                ext = os.path.splitext(file)[1].lower()
                if ext in excluded_extensions:
                    continue
                if file.endswith('.log') or 'backup' in file.lower() or 'dump' in file.lower():
                    continue
                
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, dir_path)
                zip_arc_path = rel_path.replace(os.sep, '/')
                
                zipf.write(abs_path, zip_arc_path)
                file_count += 1
                total_size += os.path.getsize(abs_path)
                
        print(f"Created {output_zip_path} containing {file_count} files ({total_size / (1024*1024):.2f} MB)")

if __name__ == '__main__':
    create_clean_zip('ResortApp', 'zeebull_backend.zip')
