# This is the first script and more reliable than the batterylogplot.sh, that was an experiment to how to graph with shell commands only
# For using this you will need to use python3
# Make sure to install python3 beforehand 

#############################################################################################################################################

#!/bin/bash
LOGFILE="battery_log.csv"

# Check and create the CSV file if it doesn't exist
if [ ! -f $LOGFILE ]; then
    echo "Timestamp,Battery_Percentage,Time_Remaining" > $LOGFILE
fi

# Function to get the current battery percentage and time remaining
get_battery_info() {
    battery_info=$(upower -i $(upower -e | grep BAT))
    battery_percentage=$(echo "$battery_info" | grep -E "percentage" | awk '{print $2}')
    
    # Check if the battery is charging or discharging and get the relevant time
    time_remaining=$(echo "$battery_info" | grep -E "(time to empty|time to full)" | awk '{print $4, $5}')
    
    # If no time remaining is available, set it to "N/A"
    if [ -z "$time_remaining" ]; then
        time_remaining="N/A"
    fi
    
    echo "$battery_percentage,$time_remaining"
}

# Infinite loop to log data every 60 seconds
while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    battery_info=$(get_battery_info)
    echo "$timestamp,$battery_info" >> $LOGFILE
    sleep 60
done

