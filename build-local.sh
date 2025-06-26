#!/bin/bash

# N64 Music Visualizer - Local Build Script
# Mimics GitHub Actions workflow for local testing

set -e

echo "🏠 N64 Music Visualizer - Local Build"
echo "===================================="

# Check if we're in the right directory
if [ ! -f "Makefile" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

# Convert audio if needed
if [ ! -f "src/intensidade-intro-mono-22050_data.c" ] || [ "intensidade-intro-mono-22050.wav" -nt "src/intensidade-intro-mono-22050_data.c" ]; then
    echo "🎵 Converting audio..."
    python3 tools/wav_to_c.py intensidade-intro-mono-22050.wav intensidade_audio
    echo "✅ Audio converted!"
else
    echo "✅ Audio already converted and up to date"
fi

# Check if libdragon is installed
if [ -z "$N64_INST" ]; then
    echo "❌ Error: N64_INST environment variable not set"
    echo "💡 Please install libdragon or use GitHub Actions for compilation"
    echo "🔗 See: https://github.com/DragonMinded/libdragon"
    exit 1
fi

if [ ! -f "$N64_INST/include/n64.mk" ]; then
    echo "❌ Error: n64.mk not found at $N64_INST/include/n64.mk"
    echo "💡 Please check your libdragon installation"
    exit 1
fi

echo "🔍 Build environment:"
echo "N64_INST=$N64_INST"
echo "PATH includes libdragon: $(echo $PATH | grep -q "$N64_INST/bin" && echo "YES" || echo "NO")"

# Build
echo "🧹 Cleaning previous build..."
make clean

echo "🔨 Building ROM..."
make -j$(nproc 2>/dev/null || echo "1")

# Verify
if [ -f "build/visualizer.z64" ]; then
    echo ""
    echo "🎉 SUCCESS! ROM compiled locally!"
    echo "================================"
    echo ""
    echo "📁 ROM: build/visualizer.z64"
    
    # Show file size
    ROM_SIZE=$(stat -f%z build/visualizer.z64 2>/dev/null || stat -c%s build/visualizer.z64 2>/dev/null || echo "unknown")
    if [ "$ROM_SIZE" != "unknown" ]; then
        ROM_SIZE_MB=$(echo "scale=2; $ROM_SIZE / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
        echo "📏 Size: ${ROM_SIZE_MB}MB"
    fi
    
    echo ""
    echo "🎮 Next steps:"
    echo "1. 💾 Copy to ED64 cartridge"
    echo "2. 🖥️  Test on N64 emulator:"
    echo "   mupen64plus build/visualizer.z64"
    echo ""
    echo "🎵 Your 'Intensidade Intro' (22050Hz) is ready!"
else
    echo "❌ ROM build failed!"
    exit 1
fi 