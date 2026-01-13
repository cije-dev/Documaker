"""
Production Launch Script for Documake
This script launches the application using Waitress WSGI server
Can be used as an alternative to the batch/PowerShell scripts
"""

import os
import sys
from waitress import serve
from app import app

# Load configuration from environment or use defaults
HOST = os.getenv('HOST', '0.0.0.0')
PORT = int(os.getenv('PORT', 8080))
THREADS = int(os.getenv('THREADS', 4))

# Try to load from .env file if it exists
if os.path.exists('.env'):
    print("Loading configuration from .env...")
    with open('.env', 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                if key == 'HOST':
                    HOST = value
                elif key == 'PORT':
                    PORT = int(value)
                elif key == 'THREADS':
                    THREADS = int(value)

# Display configuration
print("=" * 50)
print("Documake Production Server")
print("=" * 50)
print(f"Host: {HOST}")
print(f"Port: {PORT}")
print(f"Threads: {THREADS}")
print("=" * 50)
print()
print("Waitress server starting...")
print(f"Server will be available at http://{HOST}:{PORT}")
print("Press Ctrl+C to stop the server")
print()
sys.stdout.flush()

# Start the server
try:
    serve(
        app,
        host=HOST,
        port=PORT,
        threads=THREADS,
        channel_timeout=120,
        cleanup_interval=30,
        asyncore_use_poll=True
    )
except KeyboardInterrupt:
    print("\nServer stopped by user.")
    sys.exit(0)
except Exception as e:
    print(f"\nError starting server: {e}")
    sys.exit(1)

