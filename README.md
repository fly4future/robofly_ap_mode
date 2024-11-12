# RoboFly Access Point Setup

This repository contains scripts and instructions to configure a RoboFly to start in Access Point (AP) mode by default at boot. It includes handling of existing netplan configuration file, installation of `haveged` to fix entropy issues, and sets up a default gateway for connected clients.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **Hardware:** Raspberry Pi with Wi-Fi capability.
- **Operating System:** Raspberry Pi OS or any Debian-based Linux distribution.
- **Internet Connection:** Required for initial setup to install dependencies.

---

## Installation

### 1. Clone the Repository

Run the following commands:

```bash
git clone https://github.com/fly4future/robofly_ap_mode.git
cd robofly_ap_mode
```

### 2. Run the Master Installation Script

To install all dependencies, set up services, and copy files, run the following script:

```bash
chmod +x install.sh
./install.sh
```

This script installs the following:
- **`linux-wifi-hotspot`**: Provides the tools needed to set up the Wi-Fi access point.
- **`yq`**: A YAML processing tool for modifying netplan configurations.
- **`haveged`**: Ensures sufficient entropy for cryptographic operations, preventing entropy-related performance issues.

---

## Configuration

### Netplan Configuration

- The script modifies the existing netplan configuration to remove the `wifis` section, preventing conflicts with `create_ap`.
- Existing Ethernet interfaces are preserved to maintain wired network connectivity.

### Access Point Details

- **SSID:** Derived from the hostname associated with `127.0.1.1` in `/etc/hosts`. Defaults to `uav00_WIFI` if not found.
- **Password:** `${UAV_NAME}@F4F2024` (e.g., `uav00@F4F2024`).
- **Frequency Band:** Configured to use the 5GHz band if supported.
- **Default Gateway IP:** The default gateway IP for devices connecting to the access point will typically be `192.168.12.1`, or whatever IP `create_ap` assigns to the `wlan0` interface.

---

## Usage

Once the `install.sh` script returns successfully, everything should be configured properly. The AP will not start directly but will start on the next boot of the system. At all time when the AP is running you can call the `kill_ap.sh` script which will disable the AP and revert to the back up netplan configuration using the `01-netcfg.yaml.bak` file. Here are some commands that you can use with the AP: 

- **Start Access Point On Next Boot:**

  ```bash
  sudo systemctl enable setup_ap.service
  ```
This script will enable the service related to the AP and make it effective on next boot.

- **Stop Access Point and Configure Network:**

  ```bash
  clean_ap_and_configure_netplan.sh
  ```
This script will stop the AP, clean up any running processes, and guide you through configuring a new netplan setup.

- **Stop Access Point:**

  ```bash
  kill_ap.sh
  ```
This script will stop the AP and revert the previous netplan configuration.

- **Check Service Status:**

  ```bash
  sudo systemctl status setup_ap.service
  ```

- **View Logs:**

  ```bash
  sudo journalctl -u setup_ap.service
  ```

---

## Security Considerations

- **Wireless Security:** Ensure the AP password is secure. Change the default password if deploying in a sensitive environment.

---

## Troubleshooting

- **Low Entropy Detected:**

  - The `haveged` package has been installed to prevent entropy-related issues. This ensures smooth cryptographic operations (e.g., secure Wi-Fi setup).

- **Access Point Not Visible:**

  - Ensure your Raspberry Pi supports the 5GHz band.
  - For convinience, we did not put the country code into the `wpa_supplicant.conf` file but you may need to add it depending on your country. Open `/etc/wpa_supplicant/wpa_supplicant.conf` and add the following line by replacing YOUR_COUNTRY_CODE with your two-letter country code (e.g., `US`, `GB`, `FR`).
    ```bash
    country=YOUR_COUNTRY_CODE
    ```
- **Service Fails to Start:**

  - Check the service status and logs:

    ```bash
    sudo systemctl status setup_ap.service
    sudo journalctl -u setup_ap.service
    ```

  - Verify that the `setup_ap.sh` script is executable and located at `/usr/local/bin/setup_ap.sh`.

- **Network Interfaces Not Configured Correctly:**

  - Ensure that the Ethernet interfaces are correctly included in the netplan configuration.
  - Verify the contents of `/etc/netplan/01-netcfg.yaml`.

---

## Acknowledgments

- [linux-wifi-hotspot](https://github.com/lakinduakash/linux-wifi-hotspot) for providing the tools to create the access point.

---


