# Main Node Configuration Guide

## Table of Contents
- [Initial Setup](#initial-setup)
- [Storage Configuration](#storage-configuration)
- [ISO Management](#iso-management)
- [System Restore](#system-restore)
- [Network Tools](#network-tools)
- [Hardware Integration](#hardware-integration)
  - [Conbee 3 USB Stick](#conbee-3-usb-stick)
- [LXC Containers](#lxc-containers)
- [Email Notifications](#email-notifications)
- [Monitoring Stack](#monitoring-stack)
- [Wake-on-LAN Setup](#wake-on-lan-setup)
- [Automated Backup Node Management](#automated-backup-node-management)

---

## Initial Setup

### Hardware Upgrade
- **RAM**: Upgraded to 32 GB
- **OS**: Proxmox VE (PVE) installed, updated and upgraded

### Storage Connections
- **PBS Storage**: Connected to Proxmox Backup Server
- **SMB Share**: Connected from OpenMediaVault (OMV)

### Node Renaming
Configuration files to update when renaming the node:
```bash
/etc/hosts
/etc/hostname
```

---

## Storage Configuration

### Additional SSD Installation
Found and installed an additional 500 GB SSD as a directory.

**Configuration Steps:**
1. Navigate to **Datacenter → Node → Disks**
2. Select the new disk and click **Initialize Disk with GPT**
3. Go to **Disks → Directory**
4. Click **Create: Directory** and format with **XFS**

---

## ISO Management

### Transfer ISOs from Old Server

Download ISOs from the existing server via terminal:
```bash
scp root@OLD_SERVER_IP:/var/lib/vz/template/iso/* ~/Downloads/
```

Upload to new Main Node via the Proxmox GUI.

---

## System Restore

### Backup and Restore Process
1. Created backup of old system using Proxmox Backup Server (PBS)
2. Restored backup on Main Node
3. **Test**: Verified IP & MAC addresses remained unchanged
   - ✅ No network adjustments necessary

---

## Network Tools

### IP Tags Script
For easier IP management, install the IP Tags script:

**Source**: [Community Scripts - Add IP Tag](https://community-scripts.github.io/ProxmoxVE/scripts?id=add-iptag&category=Proxmox+%26+Virtualization)

---

## Hardware Integration

### Conbee 3 USB Stick

**Purpose**: MQTT integration for smart home automation

**Configuration:**
- Conbee 3 stick connected via USB
- Registered in **Datacenter** as USB device
- Passed through to MQTT container for direct access

---

## LXC Containers

### Preferred Container Stack

| Container              | Purpose                          |
|------------------------|----------------------------------|
| cloudflared            | Cloudflare tunnel                |
| mqtt                   | Message broker                   |
| zigbee2mqtt            | Zigbee smart home bridge         |
| vaultwarden            | Password manager                 |
| homarr                 | Dashboard                        |
| nginxproxymanager      | Reverse proxy                    |
| pihole                 | Network-wide ad blocking         |
| immich                 | Photo management                 |

---

## Email Notifications

### Proxmox Mail Configuration

**Setup Steps:**
1. Navigate to **Datacenter → Notifications**
2. Click **Add SMTP** and configure your SMTP server
3. **Deactivate** the default `mail-to-root` notification
4. In **default-matcher**, change **targets-to-notify** to your new SMTP configuration

---

## Monitoring Stack

### Grafana + Prometheus + PVE Exporter

**Installation:**
- Install all three components via Helper Scripts as LXC containers

**Prometheus Configuration:**
1. Edit `/etc/prometheus/prometheus.yml` (see [prometheus.yml](prometheus.yml) in this directory)

**PVE Exporter Setup:**
1. Create a new user named `prometheus` in Proxmox
2. Navigate to **Permissions**
3. Assign **PVEAuditor** role to the `prometheus` user for path `/`
4. Edit `/opt/prometheus-pve-exporter/pve.yml` with the new user credentials

---

## Wake-on-LAN Setup

### Installation

Install the Wake-on-LAN package:
```bash
apt update
apt install wakeonlan -y
```

### SSH Key Setup for PBS

**Purpose**: Enable automated shutdown of Backup Node

**Generate SSH key on PVE:**
```bash
ssh-keygen -t ed25519
```

**Copy key to PBS server:**
```bash
ssh-copy-id root@BACKUP_NODE_IP
```

**Test the connection:**
```bash
ssh root@BACKUP_NODE_IP "echo ok"
```

If it returns `ok`, the connection is working correctly.

---

## Automated Backup Node Management

### Cron Jobs for Wake-on-LAN and Shutdown

**Edit crontab:**
```bash
crontab -e
```

When prompted for an editor, choose `nano` if unsure.

**Add the following cron jobs:**

```cron
# Wake up Backup Node every Sunday at 00:30
30 0 * * 0 /usr/bin/wakeonlan BACKUP_NODE_MAC_ADDRESS

# Shutdown Backup Node every Sunday at 06:00
0 6 * * 0 ssh root@BACKUP_NODE_IP "shutdown -h now"
```

**Schedule:**
- **Sunday 00:30**: Wake up Backup Node
- **Sunday 06:00**: Shutdown Backup Node

---

## Notes

- All commands assume root access
- Backup your configuration before making changes
- Test SSH connections before setting up automated shutdown
- Adjust cron schedule based on your backup requirements
