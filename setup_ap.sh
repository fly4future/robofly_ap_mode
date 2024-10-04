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

# Define backup and current netplan files
CURRENT_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"
BACKUP_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml.bak"

# Backup netplan configuration if not already backed up
if [ ! -f "$BACKUP_NETPLAN_FILE" ]; then
    echo "Backing up netplan configuration..."
    cp "$CURRENT_NETPLAN_FILE" "$BACKUP_NETPLAN_FILE"
else
    echo "Netplan configuration backup already exists."
fi

# Remove the 'wifis' section from the netplan configuration using yq
echo "Removing the 'wifis' section using yq..."
yq e 'del(.network.wifis)' -i "$CURRENT_NETPLAN_FILE"

# Apply netplan changes
echo "Applying modified netplan configuration..."
netplan apply

# Start the access point using create_ap
echo "Starting Access Point..."
sudo create_ap --no-virt -n --freq-band "$FREQUENCY_BAND" --redirect-to-localhost wlan0 "${UAV_NAME}_WIFI" "$AP_PASSWORD"
