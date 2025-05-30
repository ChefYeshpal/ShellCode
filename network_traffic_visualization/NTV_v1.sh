#!/bin/bash

# Simple Network Traffic Visualization
# Features:
# - Real-time network traffic visualization
# - Press 'q' to exit
# - Auto-scaling based on traffic volume
# - Color-coded by traffic intensity

# Clear screen and hide cursor
clear
tput civis

# Trap to restore cursor when script exits
trap 'tput cnorm; echo; exit' EXIT INT TERM

# Color definitions
C_RESET="\033[0m"
C_HEADER="\033[1;36m"  # Bold Cyan
C_LOW="\033[1;32m"     # Bold Green
C_MED="\033[1;33m"     # Bold Yellow
C_HIGH="\033[1;31m"    # Bold Red
C_INFO="\033[1;34m"    # Bold Blue
C_BAR="\033[1;35m"     # Bold Magenta

# Terminal size
TERM_COLS=$(tput cols)
TERM_ROWS=$(tput lines)

# Interface selection
function select_interface() {
    echo -e "${C_HEADER}Available Network Interfaces:${C_RESET}"
    
    # Get list of interfaces
    interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
    
    # Display interfaces
    local i=1
    for iface in $interfaces; do
        echo "$i) $iface"
        i=$((i+1))
    done
    
    # Default to first interface if there's only one
    if [ "$(echo "$interfaces" | wc -l)" -eq 1 ]; then
        INTERFACE=$interfaces
        echo -e "Automatically selected ${C_INFO}$INTERFACE${C_RESET}"
        sleep 1
        return
    fi
    
    # Prompt for interface selection
    echo
    read -p "Select interface number (or press Enter for default): " selection
    
    if [ -z "$selection" ]; then
        INTERFACE=$(echo "$interfaces" | head -n 1)
    else
        INTERFACE=$(echo "$interfaces" | sed -n "${selection}p")
    fi
    
    if [ -z "$INTERFACE" ]; then
        echo "Invalid selection. Using default interface."
        INTERFACE=$(echo "$interfaces" | head -n 1)
    fi
    
    echo -e "Selected interface: ${C_INFO}$INTERFACE${C_RESET}"
    sleep 1
}

# Initialize storage for historical data (for simple trending)
MAX_HISTORY=60
rx_history=()
tx_history=()

# Initialize maximum seen values for scaling
max_rx=1000  # Start with 1 KB/s minimum scale
max_tx=1000  # Start with 1 KB/s minimum scale

# Get initial network stats
function get_initial_stats() {
    # Get initial RX/TX values
    if [ -f "/sys/class/net/$INTERFACE/statistics/rx_bytes" ]; then
        prev_rx=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
        prev_tx=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    else
        # Fallback to ifconfig if sysfs is not available
        stats=$(ifconfig $INTERFACE | grep -E "RX packets|TX packets")
        prev_rx=$(echo "$stats" | grep "RX packets" | awk '{print $5}')
        prev_tx=$(echo "$stats" | grep "TX packets" | awk '{print $5}')
    fi
    
    # Initialize with zeros if we couldn't get values
    prev_rx=${prev_rx:-0}
    prev_tx=${prev_tx:-0}
    
    # Initialize history with zeros
    for ((i=0; i<MAX_HISTORY; i++)); do
        rx_history[$i]=0
        tx_history[$i]=0
    done
}

# Draw a horizontal bar with given width and color
function draw_bar() {
    local width=$1
    local max_width=$2
    local color=$3
    local label=$4
    
    # Calculate actual width based on percentage of max
    local actual_width=$(( width * max_width / 100 ))
    if [ $actual_width -gt $max_width ]; then
        actual_width=$max_width
    fi
    
    # Draw the bar
    printf "${color}%-${actual_width}s${C_RESET} %s\n" "$(printf '%*s' $actual_width | tr ' ' '█')" "$label"
}

# Format bytes to human-readable format
function format_bytes() {
    local bytes=$1
    local precision=${2:-1}
    
    if [ $bytes -lt 1024 ]; then
        echo "${bytes} B/s"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(printf "%.${precision}f" $(echo "scale=$precision; $bytes/1024" | bc)) KB/s"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(printf "%.${precision}f" $(echo "scale=$precision; $bytes/1048576" | bc)) MB/s"
    else
        echo "$(printf "%.${precision}f" $(echo "scale=$precision; $bytes/1073741824" | bc)) GB/s"
    fi
}

# Get color based on value relative to maximum
function get_color() {
    local value=$1
    local max=$2
    
    local percent=$(( value * 100 / max ))
    
    if [ $percent -lt 30 ]; then
        echo $C_LOW
    elif [ $percent -lt 70 ]; then
        echo $C_MED
    else
        echo $C_HIGH
    fi
}

# Draw network statistics header
function draw_header() {
    local current_time=$(date "+%H:%M:%S")
    echo -e "${C_HEADER}Network Traffic Monitor - Interface: $INTERFACE - $current_time${C_RESET}"
    echo -e "${C_INFO}Press 'q' to exit${C_RESET}"
    echo
}

# Draw download/upload statistics
function draw_stats() {
    local rx_rate=$1
    local tx_rate=$2
    local rx_formatted=$(format_bytes $rx_rate)
    local tx_formatted=$(format_bytes $tx_rate)
    
    # Get colors based on traffic rates
    local rx_color=$(get_color $rx_rate $max_rx)
    local tx_color=$(get_color $tx_rate $max_tx)
    
    # Available width for bars (leave some room for labels)
    local bar_width=$(( TERM_COLS - 25 ))
    
    # Draw download bar
    echo -e "↓ Download: "
    draw_bar $(( rx_rate * 100 / max_rx )) $bar_width $rx_color "$rx_formatted"
    
    # Draw upload bar
    echo -e "↑ Upload:   "
    draw_bar $(( tx_rate * 100 / max_tx )) $bar_width $tx_color "$tx_formatted"
}

# Draw simple sparkline graph for history
function draw_history_graph() {
    local rx_points=()
    local tx_points=()
    local max_value=0
    local graph_width=$(( TERM_COLS > 80 ? 70 : TERM_COLS - 10 ))
    
    # Find maximum value for scaling
    for i in {0..59}; do
        if [ ${rx_history[$i]} -gt $max_value ]; then
            max_value=${rx_history[$i]}
        fi
        if [ ${tx_history[$i]} -gt $max_value ]; then
            max_value=${tx_history[$i]}
        fi
    done
    
    # Ensure minimum scale
    if [ $max_value -lt 1000 ]; then
        max_value=1000
    fi
    
    # Create sparklines
    echo
    echo -e "${C_INFO}Traffic History (Last 60 seconds):${C_RESET}"
    
    # Download history
    echo -ne "${C_LOW}↓ "
    for i in {0..59}; do
        local height=$(( ${rx_history[$i]} * 8 / max_value ))
        case $height in
            0) echo -ne " " ;;
            1) echo -ne "▁" ;;
            2) echo -ne "▂" ;;
            3) echo -ne "▃" ;;
            4) echo -ne "▄" ;;
            5) echo -ne "▅" ;;
            6) echo -ne "▆" ;;
            7) echo -ne "▇" ;;
            *) echo -ne "█" ;;
        esac
    done
    echo -e " $(format_bytes ${rx_history[59]})${C_RESET}"
    
    # Upload history
    echo -ne "${C_MED}↑ "
    for i in {0..59}; do
        local height=$(( ${tx_history[$i]} * 8 / max_value ))
        case $height in
            0) echo -ne " " ;;
            1) echo -ne "▁" ;;
            2) echo -ne "▂" ;;
            3) echo -ne "▃" ;;
            4) echo -ne "▄" ;;
            5) echo -ne "▅" ;;
            6) echo -ne "▆" ;;
            7) echo -ne "▇" ;;
            *) echo -ne "█" ;;
        esac
    done
    echo -e " $(format_bytes ${tx_history[59]})${C_RESET}"
    
    # Scale indicator
    echo -e "  ${C_INFO}0 $(format_bytes $(( max_value / 4 ))) $(format_bytes $(( max_value / 2 ))) $(format_bytes $(( max_value * 3 / 4 ))) $(format_bytes $max_value)${C_RESET}"
}

# Get network interfaces and select one
select_interface

# Get initial stats
get_initial_stats

# Main loop
update_interval=1  # seconds
counter=0

while true; do
    # Read input without blocking
    read -t 0.1 -N 1 input
    if [[ "$input" == "q" ]]; then
        break
    fi
    
    # Only update every $update_interval seconds
    if [ $counter -eq 0 ]; then
        # Clear screen
        tput cup 0 0
        
        # Get current RX/TX values
        if [ -f "/sys/class/net/$INTERFACE/statistics/rx_bytes" ]; then
            curr_rx=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
            curr_tx=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
        else
            # Fallback to ifconfig
            stats=$(ifconfig $INTERFACE | grep -E "RX packets|TX packets")
            curr_rx=$(echo "$stats" | grep "RX packets" | awk '{print $5}')
            curr_tx=$(echo "$stats" | grep "TX packets" | awk '{print $5}')
        fi
        
        # Calculate rates
        rx_rate=$(( (curr_rx - prev_rx) / update_interval ))
        tx_rate=$(( (curr_tx - prev_tx) / update_interval ))
        
        # Update history (shift left and add new value at the end)
        for i in {0..58}; do
            rx_history[$i]=${rx_history[$((i+1))]}
            tx_history[$i]=${tx_history[$((i+1))]}
        done
        rx_history[59]=$rx_rate
        tx_history[59]=$tx_rate
        
        # Update maximum seen values (with some decay to adjust scale over time)
        max_rx=$(( (max_rx * 90) / 100 ))  # 90% decay
        max_tx=$(( (max_tx * 90) / 100 ))  # 90% decay
        
        # Ensure minimum scale
        if [ $max_rx -lt 1000 ]; then
            max_rx=1000  # 1 KB/s minimum
        fi
        if [ $max_tx -lt 1000 ]; then
            max_tx=1000  # 1 KB/s minimum
        fi
        
        # Update max if current values are higher
        if [ $rx_rate -gt $max_rx ]; then
            max_rx=$rx_rate
        fi
        if [ $tx_rate -gt $max_tx ]; then
            max_tx=$tx_rate
        fi
        
        # Draw interface
        draw_header
        draw_stats $rx_rate $tx_rate
        draw_history_graph
        
        # Some interface info
        if [ -f "/sys/class/net/$INTERFACE/operstate" ]; then
            link_state=$(cat /sys/class/net/$INTERFACE/operstate)
            echo -e "\n${C_INFO}Link State: ${link_state}${C_RESET}"
        fi
        
        # Get IP address
        ip_addr=$(ip addr show $INTERFACE | grep -oP 'inet \K[\d.]+')
        if [ -n "$ip_addr" ]; then
            echo -e "${C_INFO}IP Address: ${ip_addr}${C_RESET}"
        fi
        
        # Store current values for next iteration
        prev_rx=$curr_rx
        prev_tx=$curr_tx
    fi
    
    # Increment and wrap counter
    counter=$(( (counter + 1) % (update_interval * 10) ))
    
    # Sleep a bit to reduce CPU usage
    sleep 0.1
done

exit 0
