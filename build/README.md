# 🎨 Icon Assets for Aditi Consulting AI Desktop App

## Required Icon Files

You need to add these icon files to this `build/` directory:

### 1. **icon.ico** (Windows Icon)
- **Format**: ICO file
- **Size**: 256x256 pixels (recommended)
- **Purpose**: Windows application icon, taskbar, shortcuts
- **Requirements**: 
  - Must be named exactly `icon.ico`
  - Should contain multiple sizes (16x16, 32x32, 48x48, 256x256)
  - Use your Aditi Consulting logo/branding

### 2. **icon.png** (General Icon)
- **Format**: PNG file
- **Size**: 512x512 pixels (recommended)
- **Purpose**: General application icon, about dialog
- **Requirements**:
  - Must be named exactly `icon.png`
  - High resolution for crisp display
  - Transparent background recommended
  - Use your Aditi Consulting logo/branding

## 🔧 How to Create Icons

### Option 1: Online Icon Converter
1. Take your Aditi Consulting logo (PNG/JPG)
2. Go to https://convertio.co/png-ico/ or https://icoconvert.com/
3. Upload your logo
4. Convert to ICO format with multiple sizes
5. Download and rename to `icon.ico`

### Option 2: Using GIMP (Free)
1. Open your logo in GIMP
2. Scale to 256x256 pixels
3. Export as ICO file with multiple sizes
4. Save as `icon.ico`

### Option 3: Using Photoshop
1. Open your logo
2. Resize to 256x256 pixels
3. Save for Web as PNG (for icon.png)
4. Use ICO plugin to save as ICO (for icon.ico)

## 📁 Final Structure

After adding your icons, this directory should contain:
```
build/
├── icon.ico          # Windows icon (256x256)
├── icon.png          # General icon (512x512)
└── README.md         # This file
```

## 🚀 After Adding Icons

Once you've added your icon files, you can build your desktop app:

```bash
node build-desktop.js
```

Your Aditi Consulting branding will appear in:
- Windows taskbar
- Desktop shortcuts
- Application title bar
- About dialog
- Windows Explorer file icon