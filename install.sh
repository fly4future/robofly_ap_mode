#!/bin/bash

# Store the current directory (where the script is executed)
ORIGINAL_DIR="$(pwd)"

# Define the repository URL and the target directory
REPO_URL="https://github.com/lakinduakash/linux-wifi-hotspot"
TARGET_DIR="/tmp/linux-wifi-hotspot"

# Install necessary dependencies
echo "Updating package list and installing dependencies..."
sudo apt-get update
sudo apt-get install -y libgtk-3-dev build-essential gcc g++ pkg-config make hostapd libqrencode-dev libpng-dev haveged

# Install haveged to avoid low entropy issues
echo "Starting haveged service for entropy generation..."
sudo systemctl enable haveged
sudo systemctl start haveged

# Install yq for YAML processing
echo "Installing yq for YAML editing..."
sudo wget https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_arm -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# Clone and install the linux-wifi-hotspot repository
echo "Cloning linux-wifi-hotspot repository..."
if [ -d "$TARGET_DIR" ]; then
    echo "Removing existing directory $TARGET_DIR"
    rm -rf "$TARGET_DIR"
fi

git clone "$REPO_URL" "$TARGET_DIR"

# Move into the target directory for installation
cd "$TARGET_DIR"
echo "Building and installing linux-wifi-hotspot CLI..."
make
sudo make install-cli-only

# Clean up the temporary installation directory
echo "Cleaning up temporary files..."
rm -rf "$TARGET_DIR"

# Return to the original directory to ensure correct paths for copying configuration scripts
cd "$ORIGINAL_DIR"

# Copy configuration scripts and service files
echo "Copying configuration scripts to /usr/local/bin..."
sudo cp setup_ap.sh kill_ap.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/setup_ap.sh /usr/local/bin/kill_ap.sh

echo "Copying systemd service file to /etc/systemd/system..."
sudo cp systemd_services/setup_ap.service /etc/systemd/system/

# Enable the setup_ap service
echo "Enabling the access point service..."
sudo systemctl daemon-reload
sudo systemctl enable setup_ap.service

echo "Installation and setup complete."
