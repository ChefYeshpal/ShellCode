#!/bin/bash

# Function to display Wi-Fi networks with BSSID
show_wifi_networks() {
  # Use 'nmcli' to get a list of Wi-Fi networks.
  #  and include more details.
  nmcli -f BSSID,SSID,SECURITY dev wifi | awk 'BEGIN{print "No    BSSID              SSID                                  Security"}
                                     NR>1 {
                                        if ($2 == "") {
                                          printf "%-5s  %-20s  %-35s  %s\n", NR-1, $1, "Hidden SSID", $3
                                        } else {
                                          printf "%-5s  %-20s  %-35s  %s\n", NR-1, $1, $2, $3
                                        }
                                      }'

  # Error handling
  if [ "$?" -ne "0" ]; then
    echo "Error: Failed to retrieve Wi-Fi network list.  Do you have the 'nmcli' tool installed, and do you have sufficient permissions (e.g., via sudo)?" 1>&2
    exit 1
  fi
}

# Main script logic
echo "Available Wi-Fi Networks:"
echo "------------------------------------------------"
show_wifi_networks
echo "------------------------------------------------"

