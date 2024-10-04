#!/bin/bash

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
create_ap -n --freq-band "5" --redirect-to-localhost wlan0 "${UAV_NAME}_WIFI" "${UAV_NAME}@F4F2024"
