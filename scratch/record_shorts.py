import asyncio
import os
import subprocess
from playwright.async_api import async_playwright

async def main():
    html_path = os.path.abspath(r"c:\releasing\New Orchid\scratch\zeebull_shorts.html")
    output_webm = r"C:\Users\pro\Videos\Zeebull_Happy_Client_Shorts.webm"
    output_mp4  = r"C:\Users\pro\Videos\Zeebull_Happy_Client_Shorts.mp4"
    
    os.makedirs(os.path.dirname(output_webm), exist_ok=True)

    print("Launching Chromium 9:16 Shorts recorder...")
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            viewport={'width': 1080, 'height': 1920},
            record_video_dir=r"C:\Users\pro\Videos\temp_shorts",
            record_video_size={'width': 1080, 'height': 1920}
        )
        page = await context.new_page()
        print(f"Opening {html_path}...")
        await page.goto(f"file:///{html_path}")
        
        # 36 seconds total duration for 10 complete feature scenes
        total_duration = 36
        print(f"Recording 9:16 Complete 10-Scene Short video ({total_duration} seconds)...")
        for i in range(1, total_duration + 1):
            await asyncio.sleep(1)
            if i % 6 == 0 or i == total_duration:
                print(f"Recorded {i}/{total_duration} seconds...")
                
        video_path = await page.video.path()
        await page.close()
        await context.close()
        await browser.close()
        
        if os.path.exists(output_webm):
            os.remove(output_webm)
        os.rename(video_path, output_webm)
        print(f"SUCCESS! WebM recorded: {output_webm}")

        # Convert WebM to MP4 using Playwright's ffmpeg-win64.exe executable
        ffmpeg_exe = r"C:\Users\pro\AppData\Local\ms-playwright\ffmpeg-1011\ffmpeg-win64.exe"
        if os.path.exists(ffmpeg_exe):
            cmd = f'& "{ffmpeg_exe}" -i "{output_webm}" -c:v libx264 -pix_fmt yuv420p -y "{output_mp4}"'
            print("Converting WebM to MP4...")
            subprocess.run(["powershell", "-Command", cmd])
            print(f"SUCCESS! 9:16 10-Scene Shorts MP4 Created: {output_mp4}")

if __name__ == "__main__":
    asyncio.run(main())
