#!/bin/bash

# Function to clear screen and position cursor
clear_and_center() {
    clear
    # Get terminal dimensions
    local term_height=$(tput lines)
    local term_width=$(tput cols)
    
    # Calculate center position (with some offset for time display below)
    local center_y=$((term_height / 2 - 5))
    
    # Move to center position
    for ((i=0; i<center_y; i++)); do
        echo ""
    done
}

# Function to draw the analog clock
draw_clock() {
    local hour=$1
    local minute=$2
    local term_width=$(tput cols)
    
    # Convert to 12-hour format
    hour=$((hour % 12))
    [[ $hour -eq 0 ]] && hour=12
    
    # Create a 13x13 grid with 'O' at the center
    local grid=()
    for i in {0..12}; do
        grid[$i]=$(printf "%*s" $term_width "")
    done
    
    # Center coordinates
    local center_y=6
    local center_x=$((term_width / 2))
    
    # Function to set a character at a specific position in the grid
    set_char() {
        local y=$1
        local x=$2
        local char=$3
        local line="${grid[$y]}"
        grid[$y]="${line:0:$x}$char${line:$((x+1))}"
    }
    
    # Place the center point
    set_char $center_y $center_x "O"
    
    # Calculate the positions for the minute hand (longer)
    local minute_angle=$(( (minute * 6) % 360 ))
    
    # Minute hand positions (longer hand using |, /, \, __)
    case $minute_angle in
        0|180)   # 12 or 6 o'clock
            for i in {1..5}; do
                [[ $minute_angle -eq 0 ]] && set_char $((center_y-i)) $center_x "|"
                [[ $minute_angle -eq 180 ]] && set_char $((center_y+i)) $center_x "|"
            done
            ;;
        30|210)  # 1 or 7 o'clock
            for i in {1..4}; do
                [[ $minute_angle -eq 30 ]] && set_char $((center_y-i)) $((center_x+i)) "/"
                [[ $minute_angle -eq 210 ]] && set_char $((center_y+i)) $((center_x-i)) "/"
            done
            ;;
        60|240)  # 2 or 8 o'clock
            for i in {1..5}; do
                [[ $minute_angle -eq 60 ]] && set_char $center_y $((center_x+i)) "__"
                [[ $minute_angle -eq 240 ]] && set_char $center_y $((center_x-i)) "__"
            done
            ;;
        90|270)  # 3 or 9 o'clock
            for i in {1..5}; do
                [[ $minute_angle -eq 90 ]] && set_char $center_y $((center_x+i)) "__"
                [[ $minute_angle -eq 270 ]] && set_char $center_y $((center_x-i)) "__"
            done
            ;;
        120|300) # 4 or 10 o'clock
            for i in {1..4}; do
                [[ $minute_angle -eq 120 ]] && set_char $((center_y+i)) $((center_x+i)) "\\"
                [[ $minute_angle -eq 300 ]] && set_char $((center_y-i)) $((center_x-i)) "\\"
            done
            ;;
        150|330) # 5 or 11 o'clock
            for i in {1..4}; do
                [[ $minute_angle -eq 150 ]] && set_char $((center_y+i)) $((center_x-i)) "/"
                [[ $minute_angle -eq 330 ]] && set_char $((center_y-i)) $((center_x+i)) "/"
            done
            ;;
    esac
    
    # Calculate the positions for the hour hand (shorter)
    local hour_angle=$(( (hour * 30 + minute / 2) % 360 ))
    
    # Hour hand positions (shorter hand using -)
    case $hour_angle in
        0|180)   # 12 or 6 o'clock
            for i in {1..3}; do
                [[ $hour_angle -eq 0 ]] && set_char $((center_y-i)) $center_x "-"
                [[ $hour_angle -eq 180 ]] && set_char $((center_y+i)) $center_x "-"
            done
            ;;
        30|210)  # 1 or 7 o'clock
            for i in {1..2}; do
                [[ $hour_angle -eq 30 ]] && set_char $((center_y-i)) $((center_x+i)) "-"
                [[ $hour_angle -eq 210 ]] && set_char $((center_y+i)) $((center_x-i)) "-"
            done
            ;;
        60|240)  # 2 or 8 o'clock
            for i in {1..3}; do
                [[ $hour_angle -eq 60 ]] && set_char $((center_y-1)) $((center_x+i)) "-"
                [[ $hour_angle -eq 240 ]] && set_char $((center_y+1)) $((center_x-i)) "-"
            done
            ;;
        90|270)  # 3 or 9 o'clock
            for i in {1..3}; do
                [[ $hour_angle -eq 90 ]] && set_char $center_y $((center_x+i)) "-"
                [[ $hour_angle -eq 270 ]] && set_char $center_y $((center_x-i)) "-"
            done
            ;;
        120|300) # 4 or 10 o'clock
            for i in {1..3}; do
                [[ $hour_angle -eq 120 ]] && set_char $((center_y+1)) $((center_x+i)) "-"
                [[ $hour_angle -eq 300 ]] && set_char $((center_y-1)) $((center_x-i)) "-"
            done
            ;;
        150|330) # 5 or 11 o'clock
            for i in {1..2}; do
                [[ $hour_angle -eq 150 ]] && set_char $((center_y+i)) $((center_x-i)) "-"
                [[ $hour_angle -eq 330 ]] && set_char $((center_y-i)) $((center_x+i)) "-"
            done
            ;;
    esac
    
    # Print the clock
    for line in "${grid[@]}"; do
        echo "$line"
    done
    
    # Center the time display text
    local time_text="$hour:$(printf "%02d" $minute), $(date "+%A")"
    local date_text="$(date "+%d %B, %Y.")"
    
    # Calculate padding for centering
    local time_padding=$(( (term_width - ${#time_text}) / 2 ))
    local date_padding=$(( (term_width - ${#date_text}) / 2 ))
    
    # Print time and date centered
    printf "%*s%s\n" $time_padding "" "$time_text"
    printf "%*s%s\n" $date_padding "" "$date_text"
}

# Main loop
while true; do
    clear_and_center
    current_hour=$(date +%-I)   # 12-hour format without leading zero
    current_minute=$(date +%-M) # minute without leading zero
    
    draw_clock $current_hour $current_minute
    
    # Sleep until the next minute
    sleep $((60 - $(date +%-S)))
done
