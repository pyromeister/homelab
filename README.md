# Homelab Documentation

**Deutsch** | **English**
---|---
Dokumentation meiner Homelab-Erfahrungen mit Homeservern, Proxmox, Containerisierung und Netzwerk-Konfiguration. | Documentation of my homelab experiences with home servers, Proxmox, containerization, and network configuration.

**Status**: Öffentliche Dokumentation mit Platzhaltern für sensible Daten

> **Note**: This is a public repository. All sensitive information (IPs, MACs, credentials) uses placeholders. For actual deployment, replace placeholders with your real values. See [SETUP-INSTRUCTIONS.md](#setup-instructions) for guidance.

---

## Overview

This repository documents a **four-node homelab architecture** running:
- **Proxmox VE** on two nodes (Main + GPU) for virtualization
- **OpenMediaVault** on NAS node for network storage
- **Proxmox Backup Server** on backup node for automated backups
- **23+ LXC containers** providing various services (automation, media, monitoring, infrastructure)

**Design Philosophy**: Power-efficient 24/7 operation (~22W) with on-demand GPU/backup nodes via Wake-on-LAN.

---

## Repository Structure

```
homelab/
├── README.md                    # This file - Overview and quick start
├── hardware.md                  # Hardware specifications and costs
├── #1 Main Node/               # Main 24/7 Proxmox server
│   ├── readme.md               # Setup guide, container list, monitoring
│   └── prometheus.yml          # Prometheus config template
├── #2 NAS Node/                # OpenMediaVault storage server
│   └── readme.md               # NAS setup, SMB shares, fstab config
├── #3 GPU Node/                # On-demand GPU compute node
│   ├── readme.md               # GPU node configuration
│   └── wake-on-lan.sh          # WOL script template
└── #4 Backup Node/             # Proxmox Backup Server
    └── readme.md               # PBS setup, automated WOL schedule
```

---

## Hardware Architecture

### Four-Node Setup

| Node | Hardware | OS | Power | Status |
|------|----------|----|----|--------|
| **Main Node** | Lenovo M920q (i7-8700T, 32GB) | Proxmox VE | ~12W | 24/7 |
| **NAS Node** | Lenovo M625q (AMD E2-9000E, 8GB) | OpenMediaVault | ~10W | 24/7 |
| **GPU Node** | Desktop (Ryzen 5 5600G, 32GB, Nvidia P2000) | Proxmox VE | ~100-150W | On-demand (WOL) |
| **Backup Node** | Lenovo M625q (AMD E2-9000E, 8GB) | Proxmox Backup Server | ~10W | On-demand (WOL) |

**Total 24/7 Power**: ~22W (~0.53 kWh/day, ~4.75 €/month at 0.30 €/kWh)

See [hardware.md](hardware.md) for detailed specifications and costs.

---

## Network Configuration

**Network Setup**:
- Network: `192.168.X.0/24` (flat topology, no VLANs)
- Gateway: `GATEWAY_IP` (Router)
- Primary DNS: `PRIMARY_DNS_IP` (Pi-hole)
- Secondary DNS: `GATEWAY_IP` (Router fallback)
- DHCP Range: `.100-.200`
- Static Range: `.1-.99`

**Node IPs** (use static IPs in your deployment):
- Main Node: `MAIN_NODE_IP`
- NAS Node: `NAS_NODE_IP`
- GPU Node: `GPU_NODE_IP`
- Backup Node: `BACKUP_NODE_IP`

---

## Services & Applications

### Core Infrastructure

**Proxmox VE** - Virtualization platform (Main Node + GPU Node)
**Proxmox Backup Server** - Automated backup solution (Backup Node)
**OpenMediaVault** - NAS with SMB shares (NAS Node)

### LXC Containers (Main Node)

**23+ containers** providing various services:

**Infrastructure & Networking**:
- Cloudflared - Secure tunnels for external access
- Nginx Proxy Manager - Reverse proxy for all services
- Pi-hole - DNS-based ad blocking
- Netbird - VPN mesh network

**Home Automation**:
- MQTT - Message broker
- Zigbee2MQTT - Zigbee device integration (with ConBee III USB stick)

**Media & Content**:
- Jellyfin - Media server
- Jellyseerr - Request management
- Paperless-NGX - Document management
- Immich - Photo management (testing)

**Download Automation**:
- SABnzbd - Usenet downloader
- Sonarr - TV show automation
- Radarr - Movie automation

**Monitoring**:
- Netdata - Real-time system monitoring (host-level)
- Uptime Kuma - Uptime monitoring & status page
- Patchmon - System update tracking

**Security & Workflows**:
- Vaultwarden - Self-hosted password manager
- n8n - Workflow automation

**Dashboard**:
- Homarr - Centralized service dashboard

Full container details: [#1 Main Node/readme.md](#1-main-node/readme.md)

---

## Quick Start

### Accessing Services

| Service | URL | Port | Notes |
|---------|-----|------|-------|
| Main Node (Proxmox) | `https://MAIN_NODE_IP:8006` | 8006 | Proxmox VE Web UI |
| NAS (OpenMediaVault) | `http://NAS_NODE_IP` | 80 | OMV Web UI |
| GPU Node (Proxmox) | `https://GPU_NODE_IP:8006` | 8006 | Proxmox VE Web UI |
| Backup (PBS) | `https://BACKUP_NODE_IP:8007` | 8007 | PBS Web UI |
| Pi-hole | `http://PRIMARY_DNS_IP/admin` | 80 | DNS Admin |
| Nginx Proxy Manager | `http://NGINX_IP:81` | 81 | Reverse Proxy Admin |

### Wake-on-LAN

**GPU Node**:
```bash
wakeonlan -i BROADCAST_IP GPU_NODE_MAC
```

**Backup Node** (automated via cron on Main Node):
```bash
wakeonlan -i BROADCAST_IP BACKUP_NODE_MAC
```

**Template script**: [#3 GPU Node/wake-on-lan.sh](#3-gpu-node/wake-on-lan.sh)

### Automated Backup Schedule

The Main Node automatically manages the Backup Node:
```cron
# Wake Backup Node every Sunday at 00:30
30 0 * * 0 /usr/bin/wakeonlan BACKUP_NODE_MAC

# Shutdown Backup Node every Sunday at 06:00
0 6 * * 0 ssh root@BACKUP_NODE_IP "shutdown -h now"
```

**Requirements**:
- SSH key authentication (ED25519) from Main Node to Backup Node
- Wake-on-LAN enabled on Backup Node (via `ethtool`)

See [#4 Backup Node/readme.md](#4-backup-node/readme.md) for setup details.

---

## Key Features

### Power Efficiency
- 24/7 nodes consume only ~22W combined
- GPU Node: On-demand via WOL (100-150W only when needed)
- Backup Node: 6 hours/week automated schedule
- Annual cost: ~57 € (at 0.30 €/kWh)

### Security
- All passwords in password manager (Vaultwarden)
- SSH key authentication for automation
- Cloudflare Tunnel for external access (no port forwarding)
- Air-gapped backups (Backup Node only online 6h/week)

### Automation
- Automated backup schedules via Proxmox Backup Server
- Wake-on-LAN automation for GPU/Backup nodes
- Container deployment via Proxmox Community Scripts
- Monitoring with Netdata + Uptime Kuma

---

## Setup Instructions

### Prerequisites

- Linux server hardware (or repurposed mini PCs)
- Basic networking knowledge
- Domain name (optional, for Cloudflare Tunnel)
- Password manager for credential storage

### Deployment Steps

1. **Install Proxmox VE** on Main Node
   - Follow: [#1 Main Node/readme.md](#1-main-node/readme.md)
   - Configure network, storage, email notifications

2. **Install OpenMediaVault** on NAS Node
   - Follow: [#2 NAS Node/readme.md](#2-nas-node/readme.md)
   - Set up SMB shares, mount via fstab on Proxmox

3. **Install Proxmox Backup Server** on Backup Node
   - Follow: [#4 Backup Node/readme.md](#4-backup-node/readme.md)
   - Configure WOL, SSH keys, automated schedule

4. **Optional: Install Proxmox VE** on GPU Node
   - Follow: [#3 GPU Node/readme.md](#3-gpu-node/readme.md)
   - Configure GPU passthrough if needed

5. **Deploy LXC Containers**
   - Use Proxmox Community Scripts where available
   - See [#1 Main Node/readme.md](#1-main-node/readme.md) for container list

6. **Configure Monitoring**
   - Install Netdata on Proxmox hosts
   - Deploy Uptime Kuma container
   - Optional: Prometheus + Grafana (template in `#1 Main Node/prometheus.yml`)

### Placeholder Replacement

This repository uses placeholders for sensitive information. Before deployment, replace:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `MAIN_NODE_IP` | Main Node static IP | `192.168.1.10` |
| `NAS_NODE_IP` | NAS Node static IP | `192.168.1.11` |
| `GPU_NODE_IP` | GPU Node static IP | `192.168.1.12` |
| `BACKUP_NODE_IP` | Backup Node static IP | `192.168.1.13` |
| `GATEWAY_IP` | Router/Gateway IP | `192.168.1.1` |
| `PRIMARY_DNS_IP` | Pi-hole IP | `192.168.1.3` |
| `BROADCAST_IP` | Network broadcast IP | `192.168.1.255` |
| `XX:XX:XX:XX:XX:XX` | MAC addresses | `ab:cd:ef:12:34:56` |
| `YOUR_USERNAME` | Service username | `admin` |
| `YOUR_PASSWORD` | Service password | (use password manager) |

---

## Documentation

### Node-Specific Guides

- **[#1 Main Node/readme.md](#1-main-node/readme.md)**: Proxmox setup, storage config, container list, monitoring, automation
- **[#2 NAS Node/readme.md](#2-nas-node/readme.md)**: OpenMediaVault setup, SMB shares, fstab mounting
- **[#3 GPU Node/readme.md](#3-gpu-node/readme.md)**: GPU node configuration, WOL setup
- **[#4 Backup Node/readme.md](#4-backup-node/readme.md)**: PBS setup, automated WOL/shutdown, SSH keys

### Configuration Templates

- **[#1 Main Node/prometheus.yml](#1-main-node/prometheus.yml)**: Prometheus monitoring configuration
- **[#3 GPU Node/wake-on-lan.sh](#3-gpu-node/wake-on-lan.sh)**: Wake-on-LAN automation script

---

## Troubleshooting

### Common Issues

**Container won't start**:
- Check Proxmox logs: `pct enter <CTID>` or `journalctl -xe`
- Verify storage availability
- Check network configuration

**WOL not working**:
- Verify WOL enabled in BIOS
- Check `ethtool <interface> | grep Wake-on` (should show `g`)
- Verify MAC address in script
- Firewall may block magic packets

**SMB shares not mounting**:
- Check credentials in `/etc/smbcredentials`
- Verify NAS is reachable: `ping NAS_NODE_IP`
- Check fstab syntax
- Mount manually: `mount -t cifs //NAS_NODE_IP/share /mnt/point`

---

## External Resources

- **Proxmox VE Documentation**: https://pve.proxmox.com/pve-docs/
- **Proxmox Community Scripts**: https://community-scripts.github.io/ProxmoxVE/
- **OpenMediaVault Docs**: https://docs.openmediavault.org/
- **Ubuntu Server Cheat Sheet**: https://assets.ubuntu.com/v1/3bd0daaf-Ubuntu%20Server%20CLI%20cheat%20sheet%202024%20v6.pdf
- **Docker Cheat Sheet**: https://docs.docker.com/get-started/docker_cheatsheet.pdf

---

## Contributing

This is a personal homelab documentation project. Feel free to:
- Use this as a template for your own homelab
- Submit issues for questions or clarifications
- Share your own homelab experiences

**Note**: This repository contains templates with placeholders. Do not commit actual IPs, MACs, or credentials.

---

## License

This documentation is provided as-is for educational and reference purposes.

---

## Acknowledgments

- Proxmox VE team for excellent virtualization platform
- Proxmox Community Scripts contributors
- OpenMediaVault project
- Homelab community for inspiration and knowledge sharing
