import os
import shutil
from PIL import Image, ImageFilter, ImageDraw

# Paths
ARTIFACTS_DIR = r"C:\Users\pro\.gemini\antigravity-ide\brain\788451c8-fe49-4183-a09a-94c52fe36279"
DEST_7_DIR = r"c:\releasing\New Orchid\Mobile\owner\assets\play_store_7_inch"
DEST_10_DIR = r"c:\releasing\New Orchid\Mobile\owner\assets\play_store_10_inch"

# Ensure directories exist
os.makedirs(DEST_7_DIR, exist_ok=True)
os.makedirs(DEST_10_DIR, exist_ok=True)

# The five uploaded screenshots from the current turn (ordered chronologically)
source_images = [
    "media__1779460649834.jpg", # Inventory Control
    "media__1779460654471.jpg", # Food & Beverage
    "media__1779460659312.jpg", # Finance & Accounts
    "media__1779460664082.jpg", # Booking Control
    "media__1779460668771.jpg"  # Manager Dashboard
]

names = [
    "inventory_control",
    "food_and_beverage",
    "revenue_analysis",
    "booking_control",
    "manager_dashboard"
]

def create_tablet_screenshot(src_path, dest_path, width, height, inner_height, blur_radius):
    # Load original image
    img = Image.open(src_path).convert("RGBA")
    
    # 1. Create a beautiful blurred background
    # Scale image to cover the canvas
    bg_w = width
    bg_h = int(img.height * (width / img.width))
    if bg_h < height:
        bg_h = height
        bg_w = int(img.width * (height / img.height))
        
    bg = img.resize((bg_w, bg_h), Image.Resampling.LANCZOS)
    
    # Crop to exact canvas size
    left = (bg_w - width) // 2
    top = (bg_h - height) // 2
    bg = bg.crop((left, top, left + width, top + height))
    
    # Apply blur
    bg = bg.filter(ImageFilter.GaussianBlur(blur_radius))
    
    # Apply a dark glassmorphic overlay
    overlay = Image.new("RGBA", (width, height), (15, 15, 20, 160)) # 62% opacity dark tint
    bg = Image.alpha_composite(bg, overlay)
    
    # 2. Prepare the foreground screenshot (the actual app UI)
    inner_width = int(inner_height * (img.width / img.height))
    fg = img.resize((inner_width, inner_height), Image.Resampling.LANCZOS)
    
    # Create a shadow/glow backing card
    card_margin = int(width * 0.01) # thin margin for shadow effect
    card_w = inner_width + card_margin * 2
    card_h = inner_height + card_margin * 2
    
    card = Image.new("RGBA", (card_w, card_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(card)
    
    # Draw soft rounded outer card/shadow
    r = int(width * 0.02) # corner radius
    draw.rounded_rectangle(
        [0, 0, card_w, card_h],
        radius=r,
        fill=(0, 0, 0, 80) # 30% black shadow
    )
    
    # Draw thin elegant gold border
    draw.rounded_rectangle(
        [card_margin, card_margin, card_w - card_margin, card_h - card_margin],
        radius=r,
        fill=(30, 30, 35, 255), # dark slate phone backing
        outline=(212, 175, 55, 255), # gold accent
        width=int(width * 0.005) # thin border
    )
    
    # Apply rounded corners to the screenshot itself so it fits in the phone border
    mask = Image.new("L", (inner_width, inner_height), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, inner_width, inner_height], radius=r - card_margin, fill=255)
    
    fg_rounded = Image.new("RGBA", (inner_width, inner_height))
    fg_rounded.paste(fg, (0, 0), mask=mask)
    
    # Paste screenshot onto the card
    card.paste(fg_rounded, (card_margin, card_margin), mask=fg_rounded)
    
    # Paste card onto the blurred background in the center
    paste_x = (width - card_w) // 2
    paste_y = (height - card_h) // 2
    
    bg.paste(card, (paste_x, paste_y), mask=card)
    
    # Convert back to RGB to save as JPEG/PNG
    final_img = bg.convert("RGB")
    final_img.save(dest_path, "JPEG", quality=92)
    print(f"Saved: {dest_path} ({width}x{height})")

# Process the images
for i, filename in enumerate(source_images):
    src_file_path = os.path.join(ARTIFACTS_DIR, filename)
    name = names[i]
    
    # 7-inch tablet: 1080 x 1920 (9:16 aspect ratio)
    filename_7 = f"zeebull_employee_7in_{name}.jpg"
    dest_path_7 = os.path.join(DEST_7_DIR, filename_7)
    create_tablet_screenshot(src_file_path, dest_path_7, 1080, 1920, 1550, 35)
    
    # Copy to current artifacts directory
    shutil.copy(dest_path_7, os.path.join(ARTIFACTS_DIR, filename_7))
    
    # 10-inch tablet: 1620 x 2880 (9:16 aspect ratio)
    filename_10 = f"zeebull_employee_10in_{name}.jpg"
    dest_path_10 = os.path.join(DEST_10_DIR, filename_10)
    create_tablet_screenshot(src_file_path, dest_path_10, 1620, 2880, 2350, 50)
    
    # Copy to current artifacts directory
    shutil.copy(dest_path_10, os.path.join(ARTIFACTS_DIR, filename_10))

print("Tablet screenshots generated and copied successfully!")
