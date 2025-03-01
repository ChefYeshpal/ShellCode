#!/bin/bash

# Configuration
WORK_TIME=2  # Work time in minutes
BREAK_TIME=1  # Break time in minutes
CYCLES=1      # Number of cycles

# Create log file with date-time format, and determine where the pomodoro.sh file is
SCRIPT_DIR=$(dirname "$(realpath "$0")")
LOG_FILE="$SCRIPT_DIR/pomodoro_$(date '+%Y-%m-%d_%H-%M-%S').log"

# Function to display a countdown
countdown() {
    local duration=$(( $1 * 60 ))
    local label=$2

    # Declare and then assign start_time separately to avoid masking return values
    local start_time
    start_time=$(date +%s)
    
    # Show start_time
    echo "Start Time: $start_time"
    for ((elapsed=0; elapsed<=duration; elapsed++)); do
        remaining=$(( duration - elapsed ))
        printf "\r%s: %02d:%02d elapsed, %02d:%02d remaining" \
            "$label" $((elapsed / 60)) $((elapsed % 60)) $((remaining / 60)) $((remaining % 60))
        
        echo "$(date '+%H:%M:%S') - $label: $((elapsed / 60)) min elapsed" >> "$LOG_FILE"
        
        sleep 1
    done
    echo ""
}

# Start Pomodoro cycles
echo "Starting Pomodoro Session at $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "=====================================" | tee -a "$LOG_FILE"

for ((i=1; i<=CYCLES; i++)); do
    echo "Cycle $i/$CYCLES" | tee -a "$LOG_FILE"
    
    countdown "$WORK_TIME" "Work Time"
    echo "------ Work session complete! ------" | tee -a "$LOG_FILE"
    
    countdown "$BREAK_TIME" "Break Time"
    echo "------ Break complete! ------" | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
done

echo "All cycles completed! Pomodoro session done at $(date)" | tee -a "$LOG_FILE"
echo "=====================================" | tee -a "$LOG_FILE"

