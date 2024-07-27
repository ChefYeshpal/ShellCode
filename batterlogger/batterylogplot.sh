#!/bin/bash

LOGFILE="battery_log.csv"
PLOTFILE="battery_plot.png"

# Create the log file and add headers if it doesn't exist
if [ ! -f $LOGFILE ]; then
    echo "Timestamp,Battery_Percentage" > $LOGFILE
fi

# Function to get the current battery percentage
get_battery_percentage() {
    upower -i $(upower -e | grep BAT) | grep -E "percentage" | awk '{print $2}'
}

# Infinite loop to log data every 60 seconds and plot the graph
while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    battery_percentage=$(get_battery_percentage)
    echo "$timestamp,$battery_percentage" >> $LOGFILE

    # Plot the graph using gnuplot
    gnuplot <<- EOF
        set datafile separator ","
        set terminal png size 800,600
        set output "$PLOTFILE"
        set title "Battery Percentage Over Time"
        set xlabel "Timestamp"
        set ylabel "Battery Percentage (%)"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M:%S"
        set grid
        plot "$LOGFILE" using 1:(strcol(2)) with linespoints title "Battery Percentage"
EOF

    sleep 60
done

