#!/bin/bash

# Configuration
WORK_TIME=2   # Work time in minutes
BREAK_TIME=1  # Break time in minutes
CYCLES=1      # Number of cycles

# Determine script directory and log file
SCRIPT_DIR=$(dirname "$(realpath "$0")")
LOG_FILE="$SCRIPT_DIR/pomodoro_$(date '+%d-%m-%Y').log"

# Ask for task description
echo "Enter the task you're working on:"
read -r TASK

# Log session start
SESSION_START=$(date '+%H:%M:%S')
echo "Session start: $SESSION_START"
echo ""
echo "====== $(date '+%d-%m-%Y %H:%M:%S') ======" | tee -a "$LOG_FILE"
echo "Task: $TASK" | tee -a "$LOG_FILE"

# Function to handle work/break sessions
session_timer() {
    local duration=$(( $1 * 60 ))
    local label=$2
    local start_time end_time

    start_time=$(date '+%H:%M:%S')
    echo "Start time: $start_time"
    echo ""
    echo "$(date '+%d-%m-%Y %H:%M:%S') - $label start" | tee -a "$LOG_FILE"

    # Countdown
    for ((elapsed=0; elapsed<duration; elapsed++)); do
        remaining=$(( duration - elapsed ))
        printf "\r%s: %02d:%02d remaining" \
            "$label" $((remaining / 60)) $((remaining % 60))
        sleep 1
    done
    echo ""

    end_time=$(date '+%H:%M:%S')
    echo "End Time: $end_time"
    echo ""
    echo "$(date '+%d-%m-%Y %H:%M:%S') - $label end" | tee -a "$LOG_FILE"
}

# Run Pomodoro cycles
for ((i=1; i<=CYCLES; i++)); do
    session_timer "$WORK_TIME" "Work Time"
    session_timer "$BREAK_TIME" "Break Time"
    echo "" | tee -a "$LOG_FILE"
done

# Log session end
SESSION_END=$(date '+%H:%M:%S')
echo "Session end: $SESSION_END"
echo "=====================================" >> "$LOG_FILE"

