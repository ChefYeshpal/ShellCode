#!/bin/bash
# This is the first script and more reliable than the batterylogplot.sh, that was an experiment to how to graph with shell commands only
# For using this you will need to use python3
# Make sure to install python3 beforehand 

#############################################################################################################################################

#!/bin/bash
LOGFILE="battery_log.csv"

# Check and create the CSV file if it doesn't exist
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

