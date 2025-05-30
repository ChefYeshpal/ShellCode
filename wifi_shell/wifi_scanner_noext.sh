#!/bin/bash

# Function to display Wi-Fi networks by manually scanning
show_wifi_networks() {
  # 1. Identify the wireless interface.  This is essential.
  WIRELESS_INTERFACE=$(iw dev | grep "Interface" | awk '{print $2}')

  if [ -z "$WIRELESS_INTERFACE" ]; then
    echo "Error: No wireless interface found. Please ensure you have a wireless card and driver installed." 1>&2
    exit 1
  fi

  # 2. Put the interface down
  ifconfig "$WIRELESS_INTERFACE" down

  # 3. Set the interface to monitor mode.  This is the tricky part.
  #    Check if the interface can be set to monitor mode
  if iwconfig "$WIRELESS_INTERFACE" mode monitor; then
    echo "Successfully set $WIRELESS_INTERFACE to monitor mode."
  else
    echo "Error: Failed to set $WIRELESS_INTERFACE to monitor mode.  Your card may not support this." 1>&2
    exit 1
  fi

  # 4. Bring the interface up
  ifconfig "$WIRELESS_INTERFACE" up

  # 5. Use iwlist to scan
  iwlist "$WIRELESS_INTERFACE" scan | \
  awk '
    BEGIN {
      print "No    BSSID              SSID                                  Security";
      network_count = 0;
      bssid = "";
      ssid = "";
      security = "Open";
    }
    /Cell [0-9]+/ {
      network_count++;
      bssid = substr($0, index($0, "Address:") + 9, 17);
    }
    /ESSID/ {
      ssid = substr($0, index($0, ":") + 1);
      gsub(/\"/, "", ssid);
    }
    /Encryption key:/ {
      security = "Secured";
    }
    /IE:/ {
      security = "Secured";
    }
    END {
      if (network_count == 0) {
        print "      No networks found";
      }
    }
    {
      if (bssid != prev_bssid && bssid != "") {
        printf "%-5s  %-20s  %-35s  %s\n", network_count, bssid, ssid, security;
        prev_bssid = bssid;
        bssid = "";
        ssid = "";
        security = "Open";
      }
    }
  '

  # 6.  Set the interface back to managed mode
  ifconfig "$WIRELESS_INTERFACE" down
  iwconfig "$WIRELESS_INTERFACE" mode managed
  ifconfig "$WIRELESS_INTERFACE" up
}

# Main script logic
echo "Available Wi-Fi Networks:"
echo "------------------------------------------------"
show_wifi_networks
echo "------------------------------------------------"

