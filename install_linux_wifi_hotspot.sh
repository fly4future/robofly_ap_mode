#!/bin/bash

# Install dependencies
sudo apt update
sudo apt install -y git libgtk-3-dev build-essential gcc g++ pkg-config make hostapd libqrencode-dev libpng-dev

# Define the repository URL and the target directory
REPO_URL="https://github.com/lakinduakash/linux-wifi-hotspot"
TARGET_DIR="/tmp/linux-wifi-hotspot"

# Remove existing directory if it exists
if [ -d "$TARGET_DIR" ]; then
    echo "Removing existing directory $TARGET_DIR"
    rm -rf "$TARGET_DIR"
fi

# Clone the repository
git clone "$REPO_URL" "$TARGET_DIR"

# Build and install
cd "$TARGET_DIR"
make
sudo make install-cli-only

# Clean up
rm -rf "$TARGET_DIR"

echo "linux-wifi-hotspot installed successfully."
exit 0
