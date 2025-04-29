#!/bin/bash

# Advanced Interactive Process Manager
# Features:
# - Sort by different columns
# - Search processes
# - Change process priority (nice)
# - Send various signals
# - Process tree view

# Terminal utility functions
TERM_COLS=$(tput cols)
TERM_ROWS=$(tput lines)

# Clear screen and hide cursor
clear
tput civis

# Trap to restore cursor when script exits
trap 'tput cnorm; echo; exit' EXIT INT TERM

# Color definitions
C_RESET="\033[0m"
C_HEADER="\033[1;36m"  # Bold Cyan
C_SELECTED="\033[7m"   # Reversed
C_HIGH="\033[1;31m"    # Bold Red
C_MED="\033[1;33m"     # Bold Yellow
C_LOW="\033[1;32m"     # Bold Green
C_INFO="\033[1;34m"    # Bold Blue

# Initialize variables
current_line=1
total_lines=$((TERM_ROWS - 7))  # Leave room for header and menu
offset=0
selected_pid=""
sort_column="cpu"
sort_order="-r"
filter_text=""
view_mode="standard"  # standard, tree, detailed

function print_centered() {
    local text="$1"
    local width="${2:-$TERM_COLS}"
    local padding=$(( (width - ${#text}) / 2 ))
    
    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

function get_selected_pid() {
    case "$sort_column" in
        "pid") sort_key=2 ;;
        "cpu") sort_key=3 ;;
        "mem") sort_key=4 ;;
        "time") sort_key=11 ;;
        "user") sort_key=1 ;;
        *) sort_key=3 ;;
    esac
    
    if [ -n "$filter_text" ]; then
        selected_pid=$(ps aux | grep -i "$filter_text" | grep -v "grep" | sort $sort_order -nk $sort_key | tail -n +$((offset+current_line)) | head -n 1 | awk '{print $2}')
    else
        selected_pid=$(ps aux | sort $sort_order -nk $sort_key | tail -n +$((offset+current_line)) | head -n 1 | awk '{print $2}')
    fi
}

function draw_header() {
    echo -e "${C_HEADER}"
    print_centered "INTERACTIVE PROCESS MANAGER"
    echo -e "${C_RESET}"
    
    # Display filter if active
    if [ -n "$filter_text" ]; then
        echo -e "${C_INFO}Filter: $filter_text${C_RESET}"
    fi
    
    # Display column headers with indicators for sort column
    local pid_header="PID"
    local user_header="USER"
    local cpu_header="CPU%"
    local mem_header="MEM%"
    local time_header="TIME"
    local cmd_header="COMMAND"
    
    # Add sort indicator
    case "$sort_column" in
        "pid") pid_header="$pid_header$([ "$sort_order" = "-r" ] && echo "↓" || echo "↑")" ;;
        "user") user_header="$user_header$([ "$sort_order" = "-r" ] && echo "↓" || echo "↑")" ;;
        "cpu") cpu_header="$cpu_header$([ "$sort_order" = "-r" ] && echo "↓" || echo "↑")" ;;
        "mem") mem_header="$mem_header$([ "$sort_order" = "-r" ] && echo "↓" || echo "↑")" ;;
        "time") time_header="$time_header$([ "$sort_order" = "-r" ] && echo "↓" || echo "↑")" ;;
    esac
    
    echo -e "${C_HEADER}$(printf "%-6s %-10s %-6s %-6s %-8s %s\n" "$pid_header" "$user_header" "$cpu_header" "$mem_header" "$time_header" "$cmd_header")${C_RESET}"
}

function draw_processes() {
    # First draw the header
    draw_header
    
    local line=0
    local sort_key
    
    case "$sort_column" in
        "pid") sort_key=2 ;;
        "cpu") sort_key=3 ;;
        "mem") sort_key=4 ;;
        "time") sort_key=11 ;;
        "user") sort_key=1 ;;
        *) sort_key=3 ;;
    esac
    
    # Prepare process data
    local process_data
    if [ -n "$filter_text" ]; then
        process_data=$(ps aux | grep -i "$filter_text" | grep -v "grep" | sort $sort_order -nk $sort_key)
    else
        process_data=$(ps aux | sort $sort_order -nk $sort_key)
    fi
    
    # Display process list based on view mode
    if [ "$view_mode" = "tree" ]; then
        # Tree view using pstree
        if [ -n "$filter_text" ]; then
            pstree -p | grep -i "$filter_text" | head -n $total_lines
        else
            pstree -p | head -n $total_lines
        fi
    else
        # Standard view
        echo "$process_data" | tail -n +$((offset+1)) | head -n $total_lines | while read user pid cpu mem vsz rss tty stat start time cmd; do
            line=$((line+1))
            
            # Start line formatting
            local line_format=""
            
            # Highlight selected line
            if [ $line -eq $current_line ]; then
                line_format="${C_SELECTED}"
            fi
            
            # Colorize CPU usage
            local cpu_color=""
            if (( $(echo "$cpu > 50" | bc -l 2>/dev/null) )); then
                cpu_color="${C_HIGH}"
            elif (( $(echo "$cpu > 20" | bc -l 2>/dev/null) )); then
                cpu_color="${C_MED}"
            elif (( $(echo "$cpu > 5" | bc -l 2>/dev/null) )); then
                cpu_color="${C_LOW}"
            fi
            
            # Handle potential truncation for command
            local cmd_display="$cmd"
            local max_cmd_len=$((TERM_COLS - 38))
            if [ ${#cmd_display} -gt $max_cmd_len ]; then
                cmd_display="${cmd_display:0:$max_cmd_len}..."
            fi
            
            # Print process line
            echo -e "${line_format}$(printf "%-6s %-10s ${cpu_color}%-6s${C_RESET}${line_format} %-6s %-8s %s\n" "$pid" "$user" "$cpu" "$mem" "$time" "$cmd_display")${C_RESET}"
        done
    fi
}

function search_processes() {
    tput cnorm  # Show cursor while typing
    echo -n "Search (leave empty to clear): "
    read filter_text
    tput civis  # Hide cursor again
    current_line=1
    offset=0
}

function change_sort() {
    local new_column="$1"
    
    if [ "$sort_column" = "$new_column" ]; then
        # Toggle sort order if same column
        if [ "$sort_order" = "-r" ]; then
            sort_order=""
        else
            sort_order="-r"
        fi
    else
        # Set new sort column
        sort_column="$new_column"
        # Default sort orders
        case "$new_column" in
            "cpu"|"mem") sort_order="-r" ;;  # Descending for resource usage
            *) sort_order="" ;;              # Ascending for others
        esac
    fi
    
    # Reset position
    current_line=1
    offset=0
}

function change_priority() {
    get_selected_pid
    if [ -n "$selected_pid" ]; then
        tput cnorm  # Show cursor while typing
        echo -n "Enter nice value (-20 to 19, lower is higher priority): "
        read nice_value
        tput civis  # Hide cursor again
        
        if [[ "$nice_value" =~ ^-?[0-9]+$ ]] && [ "$nice_value" -ge -20 ] && [ "$nice_value" -le 19 ]; then
            sudo renice $nice_value -p $selected_pid 2>/dev/null
            if [ $? -ne 0 ]; then
                # Try without sudo if sudo failed
                renice $nice_value -p $selected_pid 2>/dev/null
            fi
        else
            echo "Invalid nice value. Must be between -20 and 19."
            sleep 1
        fi
    fi
}

function send_signal() {
    get_selected_pid
    if [ -n "$selected_pid" ]; then
        tput cnorm  # Show cursor while typing
        echo -n "Enter signal (1-SIGHUP, 9-SIGKILL, 15-SIGTERM, etc): "
        read signal
        tput civis  # Hide cursor again
        
        kill -$signal $selected_pid 2>/dev/null
    fi
}

function show_process_details() {
    get_selected_pid
    if [ -n "$selected_pid" ]; then
        clear
        echo -e "${C_HEADER}Process Details for PID: $selected_pid${C_RESET}"
        echo "---------------------------------"
        
        # Show basic process info
        echo -e "${C_INFO}Basic Info:${C_RESET}"
        ps -p $selected_pid -o pid,ppid,user,stat,time,pcpu,pmem,command --no-headers
        
        # Process status from /proc
        if [ -d "/proc/$selected_pid" ]; then
            echo -e "\n${C_INFO}Process Status:${C_RESET}"
            cat /proc/$selected_pid/status 2>/dev/null | grep -E "Name|State|Tgid|Pid|PPid|Threads|VmSize|VmRSS|Cpus_allowed|CapEff" | head -n 10
            
            echo -e "\n${C_INFO}CPU Usage (from /proc/stat):${C_RESET}"
            cat /proc/$selected_pid/stat 2>/dev/null | awk '{print "User CPU time: " $14 "\nSystem CPU time: " $15 "\nChild user CPU time: " $16 "\nChild system CPU time: " $17}'
        fi
        
        # Open files
        echo -e "\n${C_INFO}Open Files (top 5):${C_RESET}"
        lsof -p $selected_pid 2>/dev/null | head -n 5
        
        # Environment variables
        echo -e "\n${C_INFO}Environment Variables (top 5):${C_RESET}"
        cat /proc/$selected_pid/environ 2>/dev/null | tr '\0' '\n' | head -n 5
        
        # Command line
        echo -e "\n${C_INFO}Command Line:${C_RESET}"
        cat /proc/$selected_pid/cmdline 2>/dev/null | tr '\0' ' '
        
        echo -e "\n\nPress any key to return..."
        read -rsn1
    fi
}

function toggle_view_mode() {
    if [ "$view_mode" = "standard" ]; then
        view_mode="tree"
    else
        view_mode="standard"
    fi
    current_line=1
    offset=0
}

function show_help() {
    clear
    cat << EOF
${C_HEADER}Process Monitor Help${C_RESET}
-------------------
${C_INFO}Navigation:${C_RESET}
  ↑/k: Move cursor up
  ↓/j: Move cursor down
  PgUp: Page up
  PgDn: Page down
  Home: Go to first process
  End: Go to last process
  
${C_INFO}Sorting:${C_RESET}
  1: Sort by PID
  2: Sort by USER
  3: Sort by CPU% (default)
  4: Sort by MEM%
  5: Sort by TIME
  
${C_INFO}Views:${C_RESET}
  v: Toggle between standard and tree view
  s: Search processes
  
${C_INFO}Actions:${C_RESET}
  i: Show detailed info for selected process
  k: Kill selected process (SIGTERM)
  K: Send custom signal
  n: Change process priority (nice)
  r: Refresh process list
  
${C_INFO}General:${C_RESET}
  q: Quit
  ?: Show this help

Press any key to return...
EOF
    read -rsn1
}

function handle_keys() {
    local key
    read -rsn1 key
    
    # Handle special keys (arrow keys, etc.)
    if [ "$key" = $'\e' ]; then
        read -rsn2 key
        case "$key" in
            "[A") key="k" ;;  # Up arrow
            "[B") key="j" ;;  # Down arrow
            "[5") read -rsn1 tmp; key="PgUp" ;;  # Page Up
            "[6") read -rsn1 tmp; key="PgDn" ;;  # Page Down
            "[H") key="Home" ;;  # Home
            "[F") key="End" ;;   # End
            *) ;;
        esac
    fi
    
    case "$key" in
        k|"k") # Up arrow or k
            if [ $current_line -gt 1 ]; then
                current_line=$((current_line-1))
            elif [ $offset -gt 0 ]; then
                offset=$((offset-1))
            fi
            ;;
        j|"j") # Down arrow or j
            if [ $current_line -lt $total_lines ]; then
                current_line=$((current_line+1))
            else
                offset=$((offset+1))
            fi
            ;;
        "PgUp") # Page up
            offset=$((offset-total_lines))
            if [ $offset -lt 0 ]; then
                offset=0
            fi
            ;;
        "PgDn") # Page down
            offset=$((offset+total_lines))
            ;;
        "Home") # Home - go to first process
            current_line=1
            offset=0
            ;;
        "End") # End - go to last
            offset=999999  # Some large number to go to the end
            current_line=$total_lines
            ;;
        1) # Sort by PID
            change_sort "pid"
            ;;
        2) # Sort by USER
            change_sort "user"
            ;;
        3) # Sort by CPU
            change_sort "cpu"
            ;;
        4) # Sort by MEM
            change_sort "mem"
            ;;
        5) # Sort by TIME
            change_sort "time"
            ;;
        v) # Toggle view mode
            toggle_view_mode
            ;;
        s) # Search
            search_processes
            ;;
        i) # Show process details
            show_process_details
            ;;
        k) # Kill process (SIGTERM)
            get_selected_pid
            if [ -n "$selected_pid" ]; then
                kill -15 $selected_pid 2>/dev/null
                sleep 0.5
            fi
            ;;
        K) # Send custom signal
            send_signal
            ;;
        n) # Change process priority
            change_priority
            ;;
        r) # Refresh
            # Do nothing, the screen will refresh on next loop
            ;;
        "?") # Show help
            show_help
            ;;
        q|"q") # Quit
            exit 0
            ;;
    esac
}

# Main loop
while true; do
    # Clear screen
    tput cup 0 0
    
    # Draw process list
    draw_processes
    
    # Show menu
    echo
    echo -e "${C_INFO}↑/k:Up | ↓/j:Down | 1-5:Sort | s:Search | v:View | i:Info | k:Kill | n:Nice | r:Refresh | ?:Help | q:Quit${C_RESET}"
    
    # Handle keyboard input
    handle_keys
done
