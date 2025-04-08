#!/bin/bash

# Directory where your music is stored
MUSIC_DIR="$HOME/Music/Music/Music"

# Log file to keep track of added files
LOG_FILE="$HOME/.cmus_added_files.log"

# Find new files and log them
find "$MUSIC_DIR" -type f -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2- > "$LOG_FILE"

# Get the latest 100 songs (adjust as needed)
LATEST_SONGS=$(head -n 100 "$LOG_FILE")

# Clear the existing "latest" playlist
cmus-remote -C "pl-clear latest"

# Add each song to the "latest" playlist
while IFS= read -r song; do
    cmus-remote -C "pl-add latest $song"
done <<< "$LATEST_SONGS"

# Start playing from the playlist
cmus-remote -C "player-play"

echo "Updated 'latest' playlist with recently added songs!"
