#!/bin/bash
# This is the first script and more reliable than the batterylogplot.sh, that was an experiment to how to graph with shell commands only
# For using this you will need to use python3
# Make sure to install python3 beforehand 

#############################################################################################################################################

# Defines Logfile
LOGFILE="battery_log.csv"

# Check and/or create/update the log file and add headers
if [ ! -f $LOGFILE ]; then
    echo "Timestamp,Battery_Percentage" > $LOGFILE
fi

#Function to get the current battery percentage
get_battery_percentage() {
    upower -i $(upower -e | grep BAT) | grep -E "percentage" | awk '{print $2}'
}

# upower -e lists power devices
# grep BAT filters battery devices
# upower -i provides detailed imfo abt battery. Need to use extra command with $( ) to show details, otherwise it gives NULL
# upower -i $(upower -e | grep BAT) ; prints all data abt battery and its status, grep -E 'percentage' fetches only current percentage value. awk '{print $2}' extracts only percentage value, with no 'percentage: '

# Loop to log data every 60 seconds and plot the graph
while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    battery_percentage=$(get_battery_percentage)
    echo "$timestamp,$battery_percentage" >> $LOGFILE

# While true; do,  creates loop
# Timestamp, gets current timestamp
# Battery_percentage, inserts the data from battery_percentage function
# Echo, inserts data into the logfile

    sleep 60
# Makes script sleep for 60 secs then starts it up again
done

