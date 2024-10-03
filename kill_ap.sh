#!/bin/bash

# Stop the create_ap process
echo "Stopping Access Point..."
sudo pkill create_ap

# Bring down the 'ap0' interface if it exists
if ip link show | grep -q "ap0"; then
    echo "Bringing down 'ap0' interface..."
    sudo ip link set ap0 down
fi

# Restore netplan configuration
BACKUP_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml.bak"
CURRENT_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

if [ -f "$BACKUP_NETPLAN_FILE" ]; then
    echo "Restoring original netplan configuration..."
    sudo cp "$BACKUP_NETPLAN_FILE" "$CURRENT_NETPLAN_FILE"
else
    echo "Backup netplan configuration not found. Cannot restore."
    exit 1
fi

# Apply netplan
echo "Applying restored netplan configuration..."
sudo netplan apply

echo "Access Point stopped and network configuration restored."
