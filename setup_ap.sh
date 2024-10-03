#!/bin/bash

# Get UAV_NAME from /etc/hosts associated with 127.0.1.1
UAV_NAME=$(grep -w '127.0.1.1' /etc/hosts | awk '{print $2}')
if [ -z "$UAV_NAME" ]; then
    UAV_NAME="uav00"
fi

# Define the AP password
AP_PASSWORD="${UAV_NAME}@F4F2024"

# Use the 5GHz band if supported
FREQUENCY_BAND="5"

# Start the access point using create_ap with --no-virt
echo "Starting Access Point using physical wlan0 interface..."
sudo create_ap --no-virt -n --freq-band "$FREQUENCY_BAND" --redirect-to-localhost wlan0 "${UAV_NAME}_WIFI" "$AP_PASSWORD"
