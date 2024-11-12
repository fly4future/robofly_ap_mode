#!/bin/bash

# Constants
SERVICE_NAME="setup_ap.service"
CURRENT_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"
BACKUP_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml.bak"

# Function Definitions
yesno_def_no () {
  whiptail --title "Netplan Config" --yesno "$1" --yes-button "No" --no-button "Yes" 0 0
  return $?
}

yesno_def_yes () {
  whiptail --title "Netplan Config" --yesno "$1" 0 0
  return $?
}

input_box () {
  tmp=$(whiptail --inputbox "$1" 0 0 "$2" 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then
    exit 1
  else
    echo "$tmp"
  fi
}

error_msg () {
  whiptail --title "Netplan Config" --msgbox "$1" 0 0
}

# Step 1: Stop and Disable Access Point Service
echo "Stopping the access point service..."
sudo systemctl stop "$SERVICE_NAME"
echo "Disabling the access point service..."
sudo systemctl disable "$SERVICE_NAME"

# Step 2: Remove the Existing .bak File (Previous Backup)
if [ -f "$BACKUP_NETPLAN_FILE" ]; then
  yesno_def_yes "Remove the previous netplan backup file?"
  if [ $? -eq 0 ]; then
    echo "Removing previous netplan backup file..."
    sudo rm -f "$BACKUP_NETPLAN_FILE"
  fi
fi

# Step 3: Stop the Access Point and Clean Up Interfaces
# Stop the create_ap process
echo "Stopping Access Point..."
sudo pkill create_ap

# Bring down the 'ap0' interface if it exists
if ip link show | grep -q "ap0"; then
    echo "Bringing down 'ap0' interface..."
    sudo ip link set ap0 down
fi

# Step 4: Generate New Netplan Configuration
FILENAME=/tmp/01-netcfg.yaml
rm -f "$FILENAME"
touch "$FILENAME"
echo "network:" >> "$FILENAME"
echo "  version: 2" >> "$FILENAME"
echo "  renderer: networkd" >> "$FILENAME"
echo "  ethernets:" >> "$FILENAME"

interfaces=$(ls /sys/class/net)
eths=$(echo $interfaces | grep -o "\w*eth\w*")
wlans=$(echo $interfaces | grep -o "\w*wlan\w*")

if [ -z "${eths}" ]; then
  error_msg "No Ethernet interfaces found! Continuing with Wi-Fi config."
else
  for name in ${eths}; do
    echo "    $name:" >> "$FILENAME"
    yesno_def_no "Do you want to use DHCP on $name?"
    if [ $? -eq 1 ]; then
      echo "      dhcp4: yes" >> "$FILENAME"
    else
      echo "      dhcp4: no" >> "$FILENAME"
      address=$(input_box "Enter your static IP address:" "10.10.20.101")
      echo "      addresses: [$address/24]" >> "$FILENAME"
    fi
  done
fi

if [ -n "${wlans}" ]; then
  echo "  wifis:" >> "$FILENAME"
  for name in ${wlans}; do
    echo "    $name:" >> "$FILENAME"
    yesno_def_no "Do you want to use DHCP on $name?"
    if [ $? -eq 1 ]; then
      echo "      dhcp4: yes" >> "$FILENAME"
    else
      echo "      dhcp4: no" >> "$FILENAME"
      address=$(input_box "Enter your static IP address:" "192.168.69.101")
      echo "      addresses: [$address/24]" >> "$FILENAME"
      gateway=$(input_box "Enter your gateway address:" "192.168.69.1")
      echo "      gateway4: $gateway" >> "$FILENAME"
    fi
    ap_name=$(input_box "Enter your access point name (SSID):" "mrs_ctu")
    echo "      access-points:" >> "$FILENAME"
    echo "        \"$ap_name\":" >> "$FILENAME"
    password=$(input_box "Enter your access point password:" "mikrokopter")
    echo "          password: \"$password\"" >> "$FILENAME"
  done
else
  error_msg "No Wi-Fi interfaces found."
fi

# Step 5: Display the Generated Netplan Config and Apply if Confirmed
netplan=$(cat "$FILENAME")
yesno_def_yes "This netplan was generated: \n\n $netplan \n\n Copy to /etc/netplan and apply?"
if [ $? -eq 0 ]; then
  echo "Copying netplan ..."
  sudo cp "$FILENAME" "$CURRENT_NETPLAN_FILE"
  echo "Applying netplan ..."
  sudo netplan apply
fi

# Step 6: Stop haveged if Running
if systemctl is-active --quiet haveged; then
    echo "Stopping haveged service..."
    sudo systemctl stop haveged
fi

echo "Netplan configuration applied, access point stopped, and services cleaned up."
