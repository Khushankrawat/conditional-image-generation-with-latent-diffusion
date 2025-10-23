#!/usr/bin/env python3
"""
AI Image Generator - Startup Script
Launches both the API server and web interface
"""

import subprocess
import sys
import time
import webbrowser
import os
from pathlib import Path

def check_dependencies():
    """Check if required packages are installed"""
    try:
        import torch
        import flask
        import flask_cors
        import diffusers
        print("✅ All dependencies are installed")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("Please run: pip install -r requirements.txt")
        return False

def start_api_server():
    """Start the Flask API server"""
    print("🚀 Starting API server on port 5001...")
    return subprocess.Popen([sys.executable, "api.py"])

def start_web_server():
    """Start the web interface server"""
    print("🌐 Starting web interface on port 8080...")
    return subprocess.Popen([sys.executable, "-m", "http.server", "8080"])

def main():
    """Main startup function"""
    print("🎨 AI Image Generator - Starting Up...")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not Path("api.py").exists():
        print("❌ Error: api.py not found. Please run this script from the project root.")
        sys.exit(1)
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    try:
        # Start API server
        api_process = start_api_server()
        time.sleep(2)  # Give API server time to start
        
        # Start web server
        web_process = start_web_server()
        time.sleep(1)  # Give web server time to start
        
        # Open browser
        print("🌍 Opening web interface in your browser...")
        webbrowser.open("http://localhost:8080/frontend.html")
        
        print("\n" + "=" * 50)
        print("🎉 AI Image Generator is now running!")
        print("📱 Web Interface: http://localhost:8080/frontend.html")
        print("🔧 API Endpoint: http://localhost:5001")
        print("=" * 50)
        print("\nPress Ctrl+C to stop both servers...")
        
        # Wait for user to stop
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n🛑 Shutting down servers...")
            
    except Exception as e:
        print(f"❌ Error starting servers: {e}")
        sys.exit(1)
    
    finally:
        # Clean up processes
        try:
            api_process.terminate()
            web_process.terminate()
            print("✅ Servers stopped successfully")
        except:
            pass

if __name__ == "__main__":
    main()
