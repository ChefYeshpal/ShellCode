#!/bin/bash

# Network Traffic Wave Visualization
# Features:
# - Shows network traffic as waves
# - Fixed position display values
# - Press 'q' to exit
# - Clean, consistent formatting

# Clear screen and hide cursor
clear
tput civis

# Trap to restore cursor when script exits
trap 'tput cnorm; echo; exit' EXIT INT TERM

# Color definitions
C_RESET="\033[0m"
C_HEADER="\033[1;36m"  # Bold Cyan
C_DOWN="\033[1;32m"    # Bold Green for download
C_UP="\033[1;35m"      # Bold Magenta for upload
C_INFO="\033[1;34m"    # Bold Blue for info
C_VALUE="\033[1;33m"   # Bold Yellow for values

# Terminal size
TERM_COLS=$(tput cols)
TERM_ROWS=$(tput lines)

# Max width for graph (leave room for labels)
GRAPH_WIDTH=$(( TERM_COLS - 30 ))
if [ $GRAPH_WIDTH -lt 40 ]; then
    GRAPH_WIDTH=40  # Minimum width
fi

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

# Initialize storage for historical data
HISTORY_SIZE=$(( GRAPH_WIDTH + 1 ))
rx_history=()
tx_history=()

# Initialize maximum seen values for scaling
max_rx=10000  # Start with 10 KB/s minimum scale
max_tx=10000  # Start with 10 KB/s minimum scale

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
    for ((i=0; i<HISTORY_SIZE; i++)); do
        rx_history[$i]=0
        tx_history[$i]=0
    done
}

# Format bytes to human-readable format with fixed width
function format_bytes() {
    local bytes=$1
    local precision=1
    
    if [ $bytes -lt 1024 ]; then
        printf "%8d B/s" $bytes
    elif [ $bytes -lt 1048576 ]; then
        local kb=$(echo "scale=$precision; $bytes/1024" | bc)
        printf "%8s KB/s" "$kb"
    elif [ $bytes -lt 1073741824 ]; then
        local mb=$(echo "scale=$precision; $bytes/1048576" | bc)
        printf "%8s MB/s" "$mb"
    else
        local gb=$(echo "scale=$precision; $bytes/1073741824" | bc)
        printf "%8s GB/s" "$gb"
    fi
}

# Draw the wave graph
function draw_wave_graph() {
    local history=("$@")
    local max_value=$max_rx
    if [ $max_tx -gt $max_rx ]; then
        max_value=$max_tx
    fi

    local height=10  # Height of the wave graph
    local wave=""
    
    # Loop through each row (from top to bottom)
    for ((row=height; row>=1; row--)); do
        line=""
        # For each data point in history
        for ((i=0; i<GRAPH_WIDTH; i++)); do
            index=$((HISTORY_SIZE - GRAPH_WIDTH + i))
            if [ $index -lt 0 ]; then
                index=0
            fi
            
            # Calculate threshold for this row
            threshold=$(( row * max_value / height ))
            
            # If data point exceeds threshold, display wave character
            if [ ${history[$index]} -ge $threshold ]; then
                line+="▓"
            else
                line+=" "
            fi
        done
        wave+="$line\n"
    done
    
    # Print the wave graph
    echo -e "$wave"
}

# Draw header
function draw_header() {
    local current_time=$(date "+%H:%M:%S")
    echo -e "${C_HEADER}Network Traffic Wave Visualization - $INTERFACE - $current_time${C_RESET}"
    echo -e "${C_INFO}Press 'q' to exit${C_RESET}"
    echo
}

# Draw fixed-position labels and values
function draw_fixed_values() {
    local rx_rate=$1
    local tx_rate=$2
    
    # Fixed position for values
    tput cup 4 $((GRAPH_WIDTH + 5))
    echo -e "${C_DOWN}Download: ${C_VALUE}$(format_bytes $rx_rate)${C_RESET}"
    
    tput cup 16 $((GRAPH_WIDTH + 5))
    echo -e "${C_UP}Upload:   ${C_VALUE}$(format_bytes $tx_rate)${C_RESET}"
    
    # Draw scale markers
    tput cup 3 0
    echo -e "${C_INFO}$(format_bytes $max_rx)${C_RESET}"
    
    tput cup 13 0
    echo -e "${C_INFO}$(format_bytes $max_rx)${C_RESET}"
    
    tput cup 15 0
    echo -e "${C_INFO}$(format_bytes $max_tx)${C_RESET}"
    
    tput cup 25 0
    echo -e "${C_INFO}$(format_bytes $max_tx)${C_RESET}"
}

# Draw IP information in fixed position
function draw_network_info() {
    # Get IP address
    ip_addr=$(ip addr show $INTERFACE | grep -oP 'inet \K[\d.]+')
    
    # Get link state
    if [ -f "/sys/class/net/$INTERFACE/operstate" ]; then
        link_state=$(cat /sys/class/net/$INTERFACE/operstate)
    else
        link_state="unknown"
    fi
    
    # Position at bottom of screen
    tput cup $((TERM_ROWS - 3)) 0
    echo -e "${C_INFO}IP: ${C_VALUE}${ip_addr:-Not available}${C_RESET}    ${C_INFO}Link: ${C_VALUE}${link_state}${C_RESET}"
}

# Get network interfaces and select one
select_interface

# Get initial stats
get_initial_stats

# Main loop
update_interval=1  # seconds

# Clear screen once more before starting
clear

while true; do
    # Read input without blocking
    read -t 0.1 -N 1 input
    if [[ "$input" == "q" ]]; then
        break
    fi
    
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
    for i in {0..999}; do
        if [ $i -lt $((HISTORY_SIZE-1)) ]; then
            rx_history[$i]=${rx_history[$((i+1))]}
            tx_history[$i]=${tx_history[$((i+1))]}
        fi
    done
    rx_history[$((HISTORY_SIZE-1))]=$rx_rate
    tx_history[$((HISTORY_SIZE-1))]=$tx_rate
    
    # Update maximum seen values (with some decay to adjust scale over time)
    max_rx=$(( (max_rx * 95) / 100 ))  # 95% decay
    max_tx=$(( (max_tx * 95) / 100 ))  # 95% decay
    
    # Ensure minimum scale
    if [ $max_rx -lt 10000 ]; then
        max_rx=10000  # 10 KB/s minimum
    fi
    if [ $max_tx -lt 10000 ]; then
        max_tx=10000  # 10 KB/s minimum
    fi
    
    # Update max if current values are higher
    if [ $rx_rate -gt $max_rx ]; then
        max_rx=$rx_rate
    fi
    if [ $tx_rate -gt $max_tx ]; then
        max_tx=$tx_rate
    fi
    
    # Clear screen and draw everything
    tput cup 0 0
    draw_header
    
    # Label for download
    tput cup 3 0
    echo -e "${C_DOWN}▼ Download${C_RESET}"
    
    # Draw download wave
    tput cup 4 0
    draw_wave_graph "${rx_history[@]}"
    
    # Label for upload
    tput cup 15 0
    echo -e "${C_UP}▲ Upload${C_RESET}"
    
    # Draw upload wave
    tput cup 16 0
    draw_wave_graph "${tx_history[@]}"
    
    # Draw fixed position values and network info
    draw_fixed_values $rx_rate $tx_rate
    draw_network_info
    
    # Store current values for next iteration
    prev_rx=$curr_rx
    prev_tx=$curr_tx
    
    # Sleep a bit to reduce CPU usage
    sleep 0.9
done

exit 0
