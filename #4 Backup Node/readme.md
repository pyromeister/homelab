# Backup Node Configuration Guide

## Table of Contents
- [Overview](#overview)
- [Wake-on-LAN Configuration](#wake-on-lan-configuration)
  - [Check WOL Status](#check-wol-status)
  - [Enable Wake-on-LAN](#enable-wake-on-lan)
  - [Persistent WOL Configuration](#persistent-wol-configuration)
  - [Apply Configuration](#apply-configuration)
- [Automated Management](#automated-management)
- [Notes](#notes)

---

## Overview

The Backup Node runs **Proxmox Backup Server (PBS)** and operates on-demand via Wake-on-LAN to minimize power consumption.

**Key Features:**
- Lenovo ThinkCentre M625q Tiny
- AMD E2-9000E CPU (low power)
- Runs only during scheduled backup windows
- Automated wake-up and shutdown via cron jobs

---

## Wake-on-LAN Configuration

### Check WOL Status

**Check if Wake-on-LAN is supported and enabled:**

> **Note**: Replace `enp2s0` with your actual network interface name

```bash
ethtool enp2s0 | grep Wake-on
```

**Expected output:**
```
Supports Wake-on: pumbg
Wake-on: g
```

**Status indicators:**
- `g` = Wake-on-LAN is **enabled** ✅
- `d` = Wake-on-LAN is **disabled** ❌

### Enable Wake-on-LAN

If Wake-on-LAN shows `d` instead of `g`, enable it:

```bash
ethtool -s enp2s0 wol g
```

### Persistent WOL Configuration

To ensure Wake-on-LAN remains enabled after reboot, add it to the network configuration.

**Edit network interfaces file:**
```bash
nano /etc/network/interfaces
```

**Add the `post-up` command to your network interface:**

```bash
auto enp2s0
iface enp2s0 inet static
    address BACKUP_NODE_IP
    netmask 255.255.255.0
    gateway GATEWAY_IP
    post-up /sbin/ethtool -s enp2s0 wol g
```

**Configuration breakdown:**
- `auto enp2s0`: Automatically bring up interface at boot
- `iface enp2s0 inet static`: Static IP configuration
- `address`: PBS server IP address
- `netmask`: Network subnet mask
- `gateway`: Router/gateway IP
- `post-up`: Command to run after interface comes up (enables WOL)

### Apply Configuration

**Restart networking service:**
```bash
systemctl restart networking
```

**Verify WOL is enabled:**
```bash
ethtool enp2s0 | grep Wake-on
```

Should show: `Wake-on: g` ✅

---

## Automated Management

The Backup Node is automatically managed via cron jobs on the Main Node:

**Schedule:**
- **Sunday 00:30**: Automatically wake up via WOL
- **Sunday 06:00**: Automatically shutdown after backups complete

See [Main Node Configuration](../#1%20Main%20Node/readme.md#automated-backup-node-management) for cron job details.

---

## Notes

- Wake-on-LAN must be enabled in BIOS/UEFI settings
- Network interface name (`enp2s0`) may vary - check with `ip a`
- Static IP configuration prevents network changes after reboot
- Backup Node only runs during scheduled backup windows
- Idle power consumption: ~10 W
- Ensure firewall allows WOL magic packets (UDP port 9)
