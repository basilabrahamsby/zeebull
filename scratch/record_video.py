import os
import time
from playwright.sync_api import sync_playwright

def record():
    html_path = os.path.abspath(r'c:\releasing\New Orchid\scratch\teqmates_promo.html')
    output_dir = r'C:\Users\pro\Videos'
    os.makedirs(output_dir, exist_ok=True)
    
    video_dir = os.path.join(output_dir, 'promo_recordings')
    os.makedirs(video_dir, exist_ok=True)

    print("Launching Chromium video recorder...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={'width': 1920, 'height': 1080},
            record_video_dir=video_dir,
            record_video_size={'width': 1920, 'height': 1080}
        )
        page = context.new_page()
        print(f"Opening {html_path}...")
        page.goto(f"file:///{html_path.replace('\\', '/')}")
        
        # Record 1 full loop (48 seconds)
        print("Recording video (48 seconds)...")
        for i in range(1, 49):
            time.sleep(1)
            if i % 10 == 0 or i == 48:
                print(f"Recorded {i}/48 seconds...")

        context.close()
        browser.close()
        
        # Find saved webm file
        files = [os.path.join(video_dir, f) for f in os.listdir(video_dir) if f.endswith('.webm')]
        if files:
            latest_webm = max(files, key=os.path.getmtime)
            final_mp4 = os.path.join(output_dir, "TeqMates_Promotional_Video.mp4")
            final_webm = os.path.join(output_dir, "TeqMates_Promotional_Video.webm")
            
            # Copy to final path
            import shutil
            shutil.copy(latest_webm, final_webm)
            print(f"SUCCESS! Video recorded and saved to: {final_webm}")
            
            # Convert to MP4 using Playwright's bundled ffmpeg if available
            ffmpeg_cmd = "ffmpeg"
            import subprocess
            try:
                subprocess.run([ffmpeg_cmd, "-i", final_webm, "-c:v", "libx264", "-pix_fmt", "yuv420p", "-y", final_mp4], check=True)
                print(f"MP4 Conversion complete! Final MP4 saved to: {final_mp4}")
            except Exception as e:
                print("Note: webm available. MP4 conversion error:", e)

if __name__ == "__main__":
    record()
