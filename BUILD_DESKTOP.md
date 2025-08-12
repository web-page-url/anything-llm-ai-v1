# 🚀 Building Aditi Consulting AI Desktop Application

This guide will help you build the desktop version of Aditi Consulting AI as a Windows .exe file.

## 📋 Prerequisites

- Node.js 18+ installed
- Windows environment (for building .exe files)
- All your custom UI changes already implemented

## 🔧 Quick Build

### Method 1: Automated Build Script
```bash
node build-desktop.js
```

### Method 2: Manual Build
```bash
# Install Electron dependencies
npm install --save-dev electron electron-builder

# Build the application
npm run render:build

# Create .exe files
npx electron-builder --win
```

### Method 3: Individual Build Types
```bash
# Build portable .exe only
npm run build-portable

# Build installer .exe only  
npm run build-installer

# Build both
npm run build-exe
```

## 📁 Output Files

After building, you'll find these files in the `dist/` directory:

- **AditiConsultingAI-Setup.exe** - Full installer with desktop shortcuts
- **AditiConsultingAI-Portable.exe** - Single portable executable
- **win-unpacked/** - Unpacked application files

## 🎨 Required Assets

Make sure you have these files in the `build/` directory:
- `icon.ico` - Windows icon (256x256 pixels)
- `icon.png` - General icon (512x512 pixels)

## ⚙️ Configuration

The desktop app uses these default settings:
- JWT Secret: Auto-generated secure key
- Vector DB: LanceDB (embedded)
- Storage: User's AppData directory
- Ports: 3001 (server), 8888 (collector)

## 🚀 Testing

Test your built application:
```bash
# Test portable version
./dist/AditiConsultingAI-Portable.exe

# Install and test installer version
./dist/AditiConsultingAI-Setup.exe
```

## 🔧 Troubleshooting

If build fails:
1. Ensure Node.js 18+ is installed
2. Check that all dependencies are installed
3. Verify the `build/` directory has icon files
4. Run `npm run render:build` separately first

## 📦 Distribution

Your .exe files are ready for distribution:
- **Portable**: Single file, no installation required
- **Installer**: Professional installer with shortcuts and uninstaller

Both versions include your complete custom UI and branding!