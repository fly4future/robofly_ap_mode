# ROBOFLY Access Point Setup

This repository contains scripts and instructions to configure a Raspberry Pi to start in Access Point (AP) mode by default at boot. It handles existing Ethernet interfaces, removes unnecessary checks, and uses the 5GHz band if supported.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **Hardware:** Raspberry Pi with Wi-Fi capability (e.g., Raspberry Pi 3 Model B+ or Raspberry Pi 4).
- **Operating System:** Raspberry Pi OS or any Debian-based Linux distribution.
- **Internet Connection:** Required for initial setup to install dependencies.

---

## Installation

### 1. Clone the Repository

Run the following commands:

```bash
git clone https://github.com/your-username/raspberry-pi-ap-setup.git
cd raspberry-pi-ap-setup
```
### 2. Install Dependencies

Run the installation script to install `linux-wifi-hotspot` and other dependencies:

```bash
chmod +x install_linux_wifi_hotspot.sh
./install_linux_wifi_hotspot.sh
```

### 3. Copy Scripts to Appropriate Locations

#### 3.1 `setup_ap.sh` and `kill_ap.sh`

Copy the scripts to `/usr/local/bin/` and make them executable:

```bash
sudo cp setup_ap.sh kill_ap.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/setup_ap.sh /usr/local/bin/kill_ap.sh
```

#### 3.2 `setup_ap.service`

Copy the `setup_ap.service` file to `/etc/systemd/system/`:

```bash
sudo cp systemd_services/setup_ap.service /etc/systemd/system/
```

### 4. Configure `sudo` for Passwordless Execution

Open the sudoers file using `visudo`:

```bash 
sudo visudo
```
Add the following line at the end of the file, replacing your_username with the username of RoboFly (currently it is **mrs**):

```bash 
your_username ALL=(ALL) NOPASSWD: /usr/bin/create_ap, /sbin/ip, /usr/sbin/netplan, /usr/bin/awk, /usr/bin/tee, /bin/cp, /usr/bin/grep
```

### 5. Enable and Start the Service
Reload systemd to recognize the new service and enable it to start at boot:

```bash
sudo systemctl daemon-reload
sudo systemctl enable setup_ap.service
```

## Configuration

### Netplan Configuration

 - The script modifies the existing netplan configuration to remove the `wifis` section, preventing conflicts with `create_ap`.
 - Existing Ethernet interfaces are preserved to maintain wired network connectivity.

 ### Access Point Details

 - **SSID**: Derived from the hostname associated with `127.0.1.1` in `/etc/hosts`. Defaults to `uav00_WIFI` if not found.
 - **Password**: `${UAV_NAME}@F4F2024` (e.g., `uav80@F4F2024`).
 - **Frequency Band**: Configured to use the 5GHz band not to mess with the RC.

 ## Usage

 - **Start Access Point Manually:**
 ```bash
 sudo systemctl start setup_ap.service
```
 - **Stop Access Point Manually:**
 ```bash
 kill_ap.sh
```
 - **Check Service Status:**
 ```bash
 sudo systemctl status setup_ap.service
```
 - **View Logs:**
 ```bash
 sudo journalctl -u setup_ap.service
```

## Troubleshooting

 - **Access Point Not Visible:**
    - Ensure your Raspberry Pi supports the 5GHz band.
    - For convinience, we did not put the country code into the `wpa_supplicant.conf` file but you may need to add it depending on your country. Open `/etc/wpa_supplicant/wpa_supplicant.conf` and add the following line by replacing YOUR_COUNTRY_CODE with your two-letter country code (e.g., **US**, **GB**, **FR**).
    ```bash
    country=YOUR_COUNTRY_CODE
    ```

 - **Service Fails to Start:**
    - Check the service status and logs.
    - Verify that the `setup_ap.sh` script is executable and located at `/usr/local/bin/setup_ap.sh`.

 - **Network Interfaces Not Configured Correctly:**
    - Ensure that the Ethernet interfaces are correctly included in the netplan configuration.
    - Verify the contents of `/etc/netplan/01-netcfg.yaml`.

## Acknowledgments
 - [linux-wifi-hotspot](https://github.com/lakinduakash/linux-wifi-hotspot) for providing the tools to create the access point.
