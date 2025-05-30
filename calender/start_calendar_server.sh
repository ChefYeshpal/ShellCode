#!/bin/bash

# Ensure the HTML is up-to-date
./generate_calendar_html.sh

echo "Starting local web server on http://localhost:8000"
echo "Press 'q' (and Enter) in this terminal to stop the server."

# Start the Python HTTP server in the background
# We capture its process ID (PID)
python3 -m http.server 8000 &
SERVER_PID=$!

# Function to clean up when the script exits
cleanup() {
    echo -e "\nStopping web server (PID: $SERVER_PID)..."
    kill "$SERVER_PID" 2>/dev/null # Kill the background process
    wait "$SERVER_PID" 2>/dev/null # Wait for it to terminate, suppress error if already gone
    echo "Server stopped."
    exit 0
}

# Set up a trap to call cleanup() on script exit (e.g., Ctrl+C)
trap cleanup SIGINT SIGTERM

# Loop to wait for 'q' input
while true; do
    read -n 1 -s -r -p "Press 'q' to quit: " input
    if [[ "$input" == "q" || "$input" == "Q" ]]; then
        cleanup
    fi
done
