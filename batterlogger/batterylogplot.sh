#!/bin/bash
#Made to be used with 'gnuplot', basically only shell commands


LOGFILE="battery_log.csv"
PLOTFILE="battery_plot.png"

#Check and/or create/update the log file and add headers 
if [ ! -f $LOGFILE ]; then
    echo "Timestamp,Battery_Percentage" > $LOGFILE
fi

# Function to get the current battery percentage
get_battery_percentage() {
    upower -i $(upower -e | grep BAT) | grep -E "percentage" | awk '{print $2}'
}
#upower -e lists power devices
#grep BAT filters battery devices
#upower -i provides detailed imfo abt battery. Need to use extra command with $( ) to show details, otherwise it gives NULL
#upower -i $(upower -e | grep BAT) ; prints all data abt battery and its status, grep -E 'percentage' fetches only current percentage value. awk '{print $2}' extracts only percentage value, with no 'percentage: '


#Loop to log data every 60 seconds and plot the graph
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


#while true; do,  creates loop
#timestamp, gets current timestamp
#battery_percentage, inserts the data from battery_percentage function
#echo, inserts data into the logfile
#gnuplot <<- EOF, EOF is here-document that passes commands to gnuplot to generate plot [data]
#datafile seperator, sets diff row for each data [time, battery percentage] inserted in csv file
#terminal png size, sets output format to png and specifies size
#output, sets output file for plot
#title, gives out graph the title
#xlabel/ylabel, gives x and y values [batt percentage, time]
#xdatatime and timefmt and format x, configure x axis to display time 
#grid, enables grid in plot for easier reading
#plot, plots x-axis as time and y-axis as battery percentage

    sleep 60
#makes script sleep for 60 secs then starts it back up again
done

