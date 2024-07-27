#!/bin/bash

LOGFILE="battery_log.csv"

# Create the log file and add headers if it doesn't exist
if [ ! -f $LOGFILE ]; then
    echo "Timestamp,Battery_Percentage" > $LOGFILE
fi

# Function to get the current battery percentage
get_battery_percentage() {
    upower -i $(upower -e | grep BAT) | grep -E "percentage" | awk '{print $2}'
}

# Infinite loop to log data every 60 seconds
while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    battery_percentage=$(get_battery_percentage)
    echo "$timestamp,$battery_percentage" >> $LOGFILE
    sleep 60
done

