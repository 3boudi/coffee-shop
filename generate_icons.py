#!/usr/bin/env python3
"""
Icon generator script for Flutter coffee cart app
Generates icons in all required sizes for Android, iOS, macOS, Web, and Windows
"""

import os
import subprocess
from pathlib import Path

def run_command(command):
    """Run a command and return success status"""
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✓ {command}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ {command}")
        print(f"Error: {e.stderr}")
        return False

def create_directory(path):
    """Create directory if it doesn't exist"""
    Path(path).mkdir(parents=True, exist_ok=True)

def generate_png_from_svg(svg_path, output_path, size):
    """Generate PNG from SVG using ImageMagick or Inkscape"""
    # Try ImageMagick first
    command = f'magick "{svg_path}" -resize {size}x{size} "{output_path}"'
    if run_command(command):
        return True
    
    # Try Inkscape as fallback
    command = f'inkscape "{svg_path}" --export-png="{output_path}" --export-width={size} --export-height={size}'
    if run_command(command):
        return True
    
    print(f"Failed to generate {output_path}")
    return False

def main():
    svg_path = "assets/icon/coffee_cart_icon.svg"
    
    if not os.path.exists(svg_path):
        print(f"Error: {svg_path} not found!")
        return
    
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
        output_path = f"{folder}/ic_launcher.png"
        generate_png_from_svg(svg_path, output_path, size)
    
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
        generate_png_from_svg(svg_path, output_path, size)
    
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
        generate_png_from_svg(svg_path, output_path, size)
    
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
        generate_png_from_svg(svg_path, output_path, size)
    
    # Windows icon (ICO format)
    print("Generating Windows icon...")
    # First generate a 256x256 PNG
    temp_png = "temp_icon_256.png"
    if generate_png_from_svg(svg_path, temp_png, 256):
        # Convert to ICO
        ico_command = f'magick "{temp_png}" "windows/runner/resources/app_icon.ico"'
        if run_command(ico_command):
            os.remove(temp_png)
        else:
            print("Failed to generate Windows ICO file")
    
    print("\nIcon generation complete!")
    print("Note: Make sure you have ImageMagick or Inkscape installed to generate the icons.")

if __name__ == "__main__":
    main()