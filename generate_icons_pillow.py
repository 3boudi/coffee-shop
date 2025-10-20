#!/usr/bin/env python3
"""
Icon generator script for Flutter coffee cart app using Pillow
Generates icons in all required sizes for Android, iOS, macOS, Web, and Windows
"""

import os
from pathlib import Path
from PIL import Image, ImageDraw

def create_directory(path):
    """Create directory if it doesn't exist"""
    Path(path).mkdir(parents=True, exist_ok=True)

def create_coffee_cart_icon(size):
    """Create a coffee cart icon programmatically"""
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factor for different sizes
    scale = size / 1024
    
    # Background circle
    margin = int(20 * scale)
    draw.ellipse([margin, margin, size-margin, size-margin], fill=(139, 69, 19, 255))  # Brown
    
    # Cart body
    cart_x = int(200 * scale)
    cart_y = int(400 * scale)
    cart_w = int(400 * scale)
    cart_h = int(200 * scale)
    
    # Main cart rectangle
    draw.rectangle([cart_x, cart_y, cart_x + cart_w, cart_y + cart_h], 
                  fill=(210, 105, 30, 255))  # Chocolate
    
    # Inner cart rectangle
    inner_margin = int(20 * scale)
    draw.rectangle([cart_x + inner_margin, cart_y + inner_margin, 
                   cart_x + cart_w - inner_margin, cart_y + cart_h - inner_margin], 
                  fill=(244, 164, 96, 255))  # Sandy brown
    
    # Cart wheels
    wheel1_x = int(280 * scale)
    wheel2_x = int(520 * scale)
    wheel_y = int(650 * scale)
    wheel_r = int(40 * scale)
    
    # Outer wheels
    draw.ellipse([wheel1_x - wheel_r, wheel_y - wheel_r, 
                 wheel1_x + wheel_r, wheel_y + wheel_r], 
                fill=(101, 67, 33, 255))  # Dark brown
    draw.ellipse([wheel2_x - wheel_r, wheel_y - wheel_r, 
                 wheel2_x + wheel_r, wheel_y + wheel_r], 
                fill=(101, 67, 33, 255))
    
    # Inner wheels
    inner_wheel_r = int(25 * scale)
    draw.ellipse([wheel1_x - inner_wheel_r, wheel_y - inner_wheel_r, 
                 wheel1_x + inner_wheel_r, wheel_y + inner_wheel_r], 
                fill=(139, 69, 19, 255))
    draw.ellipse([wheel2_x - inner_wheel_r, wheel_y - inner_wheel_r, 
                 wheel2_x + inner_wheel_r, wheel_y + inner_wheel_r], 
                fill=(139, 69, 19, 255))
    
    # Cart handle
    handle_x = int(180 * scale)
    handle_y = int(450 * scale)
    handle_w = int(20 * scale)
    handle_h = int(100 * scale)
    
    draw.rectangle([handle_x, handle_y, handle_x + handle_w, handle_y + handle_h], 
                  fill=(101, 67, 33, 255))
    
    # Handle grip
    grip_x = int(160 * scale)
    grip_y = int(440 * scale)
    grip_w = int(60 * scale)
    grip_h = int(20 * scale)
    
    draw.rectangle([grip_x, grip_y, grip_x + grip_w, grip_y + grip_h], 
                  fill=(101, 67, 33, 255))
    
    # Coffee cup on cart
    cup_x = int(400 * scale)
    cup_y = int(480 * scale)
    cup_w = int(120 * scale)
    cup_h = int(80 * scale)
    
    # Cup base (white)
    draw.ellipse([cup_x - cup_w//2, cup_y - cup_h//2, 
                 cup_x + cup_w//2, cup_y + cup_h//2], 
                fill=(255, 255, 255, 255))
    
    # Coffee in cup (brown)
    coffee_h = int(60 * scale)
    draw.ellipse([cup_x - int(100 * scale)//2, cup_y - coffee_h//2, 
                 cup_x + int(100 * scale)//2, cup_y + coffee_h//2], 
                fill=(139, 69, 19, 255))
    
    # Coffee surface (darker brown)
    surface_h = int(50 * scale)
    draw.ellipse([cup_x - int(90 * scale)//2, cup_y - surface_h//2, 
                 cup_x + int(90 * scale)//2, cup_y + surface_h//2], 
                fill=(210, 105, 30, 255))
    
    # Canopy/umbrella (simplified as rectangle)
    canopy_y = int(300 * scale)
    canopy_h = int(30 * scale)
    draw.rectangle([int(150 * scale), canopy_y, int(650 * scale), canopy_y + canopy_h], 
                  fill=(255, 107, 107, 255))  # Light red
    
    # Canopy pole
    pole_x = int(400 * scale)
    draw.rectangle([pole_x - int(10 * scale), canopy_y, 
                   pole_x + int(10 * scale), cart_y], 
                  fill=(101, 67, 33, 255))
    
    return img

def generate_icon_files():
    """Generate all required icon files"""
    
    # Android icons (mipmap folders)
    android_icons = [
        ("android/app/src/main/res/mipmap-mdpi", 48),
        ("android/app/src/main/res/mipmap-hdpi", 72),
        ("android/app/src/main/res/mipmap-xhdpi", 96),
        ("android/app/src/main/res/mipmap-xxhdpi", 144),
        ("android/app/src/main/res/mipmap-xxxhdpi", 192),
    ]
    
    print("Generating Android icons...")
    for folder, size in android_icons:
        create_directory(folder)
        icon = create_coffee_cart_icon(size)
        output_path = f"{folder}/ic_launcher.png"
        icon.save(output_path, "PNG")
        print(f"Created {output_path}")
    
    # iOS icons
    ios_icons = [
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", 20),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", 40),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", 60),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", 29),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", 58),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", 87),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", 40),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", 80),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", 120),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", 120),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", 180),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", 76),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", 152),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", 167),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", 1024),
    ]
    
    print("Generating iOS icons...")
    for output_path, size in ios_icons:
        icon = create_coffee_cart_icon(size)
        icon.save(output_path, "PNG")
        print(f"Created {output_path}")
    
    # macOS icons
    macos_icons = [
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png", 16),
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png", 32),
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png", 64),
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png", 128),
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png", 256),
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png", 512),
        ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png", 1024),
    ]
    
    print("Generating macOS icons...")
    for output_path, size in macos_icons:
        icon = create_coffee_cart_icon(size)
        icon.save(output_path, "PNG")
        print(f"Created {output_path}")
    
    # Web icons
    web_icons = [
        ("web/favicon.png", 32),
        ("web/icons/Icon-192.png", 192),
        ("web/icons/Icon-512.png", 512),
        ("web/icons/Icon-maskable-192.png", 192),
        ("web/icons/Icon-maskable-512.png", 512),
    ]
    
    print("Generating Web icons...")
    for output_path, size in web_icons:
        icon = create_coffee_cart_icon(size)
        icon.save(output_path, "PNG")
        print(f"Created {output_path}")
    
    # Windows icon (ICO format)
    print("Generating Windows icon...")
    icon_256 = create_coffee_cart_icon(256)
    icon_256.save("windows/runner/resources/app_icon.ico", "ICO")
    print("Created windows/runner/resources/app_icon.ico")
    
    print("\nIcon generation complete!")

if __name__ == "__main__":
    try:
        generate_icon_files()
    except ImportError:
        print("Error: Pillow library not found. Please install it with: pip install Pillow")
    except Exception as e:
        print(f"Error: {e}")