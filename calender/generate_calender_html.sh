#!/bin/bash
#filename: generate_calender_html.sh
#


EVENTS_FILE="events.txt"
HTML_FILE="index.html"

# Function to get events for a specific month and year
get_events_for_month() {
    local year="$1"
    local month="$2"
    grep "^$year-$(printf "%02d" $month)-" "$EVENTS_FILE" | sed "s/^$year-$(printf "%02d" $month)-\([0-9]\{2\}\) /\1: /" | sort -n
}

# Generate the HTML file
echo "<!DOCTYPE html>" > "$HTML_FILE"
echo "<html lang=\"en\">" >> "$HTML_FILE"
echo "<head>" >> "$HTML_FILE"
echo "    <meta charset=\"UTF-8\">" >> "$HTML_FILE"
echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" >> "$HTML_FILE"
echo "    <title>My Simple Local Calendar</title>" >> "$HTML_FILE"
echo "    <style>" >> "$HTML_FILE"
echo "        body { font-family: monospace; white-space: pre; background-color: #f0f0f0; padding: 20px; }" >> "$HTML_FILE"
echo "        h1 { color: #333; }" >> "$HTML_FILE"
echo "        .calendar-section { background-color: white; border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius: 8px; box-shadow: 2px 2px 5px rgba(0,0,0,0.1); }" >> "$HTML_FILE"
echo "        .events-section { background-color: white; border: 1px solid #ccc; padding: 15px; border-radius: 8px; box-shadow: 2px 2px 5px rgba(0,0,0,0.1); }" >> "$HTML_FILE"
echo "        .event-item { margin-bottom: 5px; }" >> "$HTML_FILE"
echo "        strong { color: #007bff; }" >> "$HTML_FILE"
echo "        .month-header { font-weight: bold; font-size: 1.2em; margin-bottom: 10px; }" >> "$HTML_FILE"
echo "    </style>" >> "$HTML_FILE"
echo "</head>" >> "$HTML_FILE"
echo "<body>" >> "$HTML_FILE"
echo "    <h1>Local Calendar & Events</h1>" >> "$HTML_FILE"

# Get current year and month
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)

# Display current month's calendar and events
echo "    <div class=\"calendar-section\">" >> "$HTML_FILE"
echo "        <div class=\"month-header\">$(date +"%B %Y")</div>" >> "$HTML_FILE"
echo "        <code>" >> "$HTML_FILE"
cal >> "$HTML_FILE" # Output of cal command directly into HTML
echo "        </code>" >> "$HTML_FILE"
echo "    </div>" >> "$HTML_FILE"

# Display next month's calendar and events (optional)
NEXT_MONTH_DATE=$(date -d "next month" "+%Y-%m")
NEXT_YEAR=$(echo $NEXT_MONTH_DATE | cut -d'-' -f1)
NEXT_MONTH=$(echo $NEXT_MONTH_DATE | cut -d'-' -f2)

echo "    <div class=\"calendar-section\">" >> "$HTML_FILE"
echo "        <div class=\"month-header\">$(date -d "next month" +"%B %Y")</div>" >> "$HTML_FILE"
echo "        <code>" >> "$HTML_FILE"
cal -h "$NEXT_MONTH" "$NEXT_YEAR" >> "$HTML_FILE"
echo "        </code>" >> "$HTML_FILE"
echo "    </div>" >> "$HTML_FILE"

echo "    <div class=\"events-section\">" >> "$HTML_FILE"
echo "        <h2>Upcoming Events</h2>" >> "$HTML_FILE"
echo "        <ul>" >> "$HTML_FILE"

# Loop through future events and add them to the HTML
# Sort events by date and filter out past events
sort -k1 "$EVENTS_FILE" | while read line; do
    EVENT_DATE_STR=$(echo "$line" | awk '{print $1}')
    EVENT_TITLE=$(echo "$line" | cut -d' ' -f2-)
    
    # Convert event date string to seconds since epoch
    EVENT_EPOCH=$(date -d "$EVENT_DATE_STR" +%s 2>/dev/null)
    CURRENT_EPOCH=$(date +%s)

    # Check if the date conversion was successful and event is in the future or today
    if [ -n "$EVENT_EPOCH" ] && [ "$EVENT_EPOCH" -ge "$CURRENT_EPOCH" ]; then
        FORMATTED_DATE=$(date -d "$EVENT_DATE_STR" +"%A, %B %d, %Y")
        echo "            <li class=\"event-item\"><strong>$FORMATTED_DATE:</strong> $EVENT_TITLE</li>" >> "$HTML_FILE"
    fi
done

echo "        </ul>" >> "$HTML_FILE"
echo "    </div>" >> "$HTML_FILE"
echo "</body>" >> "$HTML_FILE"
echo "</html>" >> "$HTML_FILE"

echo "HTML calendar generated at $HTML_FILE"
