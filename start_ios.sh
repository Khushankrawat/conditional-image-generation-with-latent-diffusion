#!/bin/bash

# AI Image Generator - iOS Launch Script
# This script starts the Python API server and opens the iOS app

echo "📱 AI Image Generator - iOS Edition"
echo "===================================="

# Check if we're in the right directory
if [ ! -f "api.py" ]; then
    echo "❌ Error: api.py not found. Please run this script from the project root."
    exit 1
fi

# Check if Python API server is already running
if lsof -Pi :5001 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ API server is already running on port 5001"
else
    echo "🚀 Starting Python API server..."
    python api.py &
    API_PID=$!
    echo "📡 API server started with PID: $API_PID"
    
    # Wait a moment for the server to start
    sleep 3
fi

# Check if iOS project exists
IOS_PROJECT="AIImageGenerator-iOS/AIImageGenerator.xcodeproj"
if [ ! -d "$IOS_PROJECT" ]; then
    echo "❌ Error: iOS project not found at $IOS_PROJECT"
    echo "Please make sure the iOS project is in the correct location."
    exit 1
fi

echo "📱 Opening iOS app in Xcode..."
open "$IOS_PROJECT"

echo ""
echo "🎉 Setup Complete!"
echo "📱 iOS App: Opening in Xcode"
echo "🔧 API Server: http://localhost:5001"
echo ""
echo "📋 Next Steps:"
echo "1. Build and run the iOS app in Xcode (Cmd+R)"
echo "2. Choose your iOS device or simulator"
echo "3. The app will automatically connect to the API server"
echo "4. Start generating amazing images!"
echo ""
echo "📝 Note: Make sure your iOS device/simulator is on the same network"
echo "   as your Mac to access the API server."
echo ""
echo "Press Ctrl+C to stop the API server when done."

# Wait for user interrupt
trap 'echo ""; echo "🛑 Stopping API server..."; kill $API_PID 2>/dev/null; echo "✅ API server stopped"; exit 0' INT
wait
