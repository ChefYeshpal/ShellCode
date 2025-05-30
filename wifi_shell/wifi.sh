#!/bin/bash

# Function to scan for Wi-Fi networks
scan_wifi() {
  echo "Searching for Wi-Fi networks..."
  iw wlan0 scan |
    grep -E "^BSS|SSID|signal" |
    awk '
      /^BSS/ {
        bssid = $2;
      }
      /^SSID:/ {
        gsub(/^SSID: /, "", $0);
        ssid = $0;
      }
      /^signal:/ {
        signal = $2;
        printf "%s|%s|%s\n", ssid, bssid, signal;
      }
    '
}

# Function to display the list of networks
display_networks() {
  local networks="$1"
  local count=1
  echo "Available Wi-Fi Networks:"
  if [ -z "$networks" ]; then
    echo "No Wi-Fi networks found."
    return 1 # Return 1 to indicate no networks found
  fi
  while IFS='|' read -r ssid bssid signal; do
    network_array+=("$ssid|$bssid|$signal") # Store SSID, BSSID, and signal
    echo "$count. SSID: $ssid (BSSID: $bssid, Signal: $signal dBm)"
    ((count++))
  done <<< "$networks"
  return 0 # Return 0 to indicate success
}

# Function to connect to a Wi-Fi network using nmcli
connect_wifi() {
  local ssid="$1"
  local password="$2"

  echo "Attempting to connect to '$ssid'..."
  if nmcli dev wifi connect "$ssid" password "$password"; then
    echo "Successfully connected to '$ssid'."
    return 0
  else
    echo "Failed to connect to '$ssid'. Please check the password or network configuration."
    return 1
  fi
}

# Main script
echo "--- Starting Script ---" # Debugging output
networks=$(scan_wifi)
echo "--- After scan_wifi ---" # Debugging output
echo "networks variable: '$networks'" # Debugging output
if [ $? -ne 0 ]; then
  echo "Could not retrieve Wi-Fi networks."
  exit 1
fi

declare -a network_array
if ! display_networks "$networks"; then
  exit 1
fi

read -p "Select the number of the network you want to connect to: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#network_array[@]} )); then
  echo "Invalid choice."
  exit 1
fi

selected_network="${network_array[$((choice - 1))]}"
selected_ssid=$(echo "$selected_network" | cut -d'|' -f1)

# Prompt for password
read -s -p "Password for '$selected_ssid' (leave blank if open): " password
echo

# Connection loop
while true; do
  if connect_wifi "$selected_ssid" "$password"; then
    break
  else
    read -s -p "Retry password (wrong): " password
    echo
  fi
done

echo "Exiting."
