// build-desktop.js
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

console.log('🚀 Building Aditi Consulting AI Desktop App...');

try {
  // Install Electron dependencies
  console.log('📦 Installing Electron dependencies...');
  execSync('npm install --save-dev electron electron-builder', { stdio: 'inherit' });

  // Build the application
  console.log('🏗️ Building application...');
  execSync('npm run render:build', { stdio: 'inherit' });

  // Build Electron app
  console.log('⚡ Creating .exe files...');
  execSync('npx electron-builder --win', { stdio: 'inherit' });

  console.log('✅ Build completed successfully!');
  console.log('📦 Your .exe files are in the dist/ directory:');
  console.log('   - AditiConsultingAI-Setup.exe (Installer)');
  console.log('   - AditiConsultingAI-Portable.exe (Portable)');

} catch (error) {
  console.error('❌ Build failed:', error.message);
  process.exit(1);
}