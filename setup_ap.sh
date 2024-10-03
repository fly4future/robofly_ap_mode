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

# Backup netplan configuration if not already backed up
CURRENT_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"
BACKUP_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml.bak"

if [ ! -f "$BACKUP_NETPLAN_FILE" ]; then
    echo "Backing up netplan configuration..."
    sudo cp "$CURRENT_NETPLAN_FILE" "$BACKUP_NETPLAN_FILE"
else
    echo "Netplan configuration backup already exists."
fi

# Remove the 'wifis' section from the netplan configuration
echo "Modifying netplan configuration to remove 'wifis' section..."
sudo awk '
/^\s*wifis:/ {flag=1; next}
flag && /^\s*[^ ]/ {flag=0}
!flag {print}
' "$BACKUP_NETPLAN_FILE" | sudo tee "$CURRENT_NETPLAN_FILE" > /dev/null

# Apply netplan
echo "Applying modified netplan configuration..."
sudo netplan apply

# Start the access point using create_ap
echo "Starting Access Point..."
sudo create_ap -n --freq-band "$FREQUENCY_BAND" --redirect-to-localhost wlan0 "${UAV_NAME}_WIFI" "$AP_PASSWORD"
