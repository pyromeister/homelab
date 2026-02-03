# Services Overview

Documentation of all services running in the homelab, primarily as LXC containers on the Main Node.

**Status**: Public documentation with placeholders for sensitive information

---

## Service Architecture

### Distribution

| Location | Infrastructure | Services Count |
|----------|---------------|----------------|
| **Main Node** | Proxmox VE | 23 LXC containers (22 running, 1 stopped) |
| **NAS Node** | OpenMediaVault | Storage services (SMB, NFS) |
| **GPU Node** | Proxmox VE | 3 LXC containers (on-demand) |
| **Backup Node** | Proxmox Backup Server | Backup services |
| **Hosts** | Proxmox VE | Netdata monitoring (Main + GPU) |

---

## Services by Category

### Infrastructure & Networking

Core infrastructure services that other services depend on.

| Service | Container | Purpose | Web UI Port | Status |
|---------|-----------|---------|-------------|--------|
| **Cloudflared** | CT 101 | Secure external access via Cloudflare Tunnel (no port forwarding) | - | Critical |
| **Nginx Proxy Manager** | CT 106 | Reverse proxy for all web services, SSL termination | 81 (admin) | Critical |
| **Pi-hole** | CT 108 | DNS-based ad blocking, local DNS resolution | 80 | Critical |
| **Netbird** | CT 121 | VPN mesh network for secure remote access | - | Optional |

**Critical Services** should have static IPs or DHCP reservations.

---

### Home Automation

Services for smart home integration and automation.

| Service | Container | Purpose | Web UI Port | Dependencies |
|---------|-----------|---------|-------------|--------------|
| **MQTT** | CT 102 | Message broker for IoT devices and automation | - | Required for Zigbee2MQTT |
| **Zigbee2MQTT** | CT 103 | Zigbee device integration (requires ConBee III USB stick) | 8080 | MQTT broker |

**Hardware Required**: ConBee III USB stick passed through to CT 103 from Main Node.

**Setup**:
- Configure ConBee III USB passthrough in Proxmox (datacenter level)
- MQTT broker must be running before Zigbee2MQTT starts
- Web UI allows device pairing and management

---

### Media Services

Media streaming, management, and content organization.

| Service | Container | Purpose | Web UI Port | Storage |
|---------|-----------|---------|-------------|---------|
| **Jellyfin** | CT 113 | Media server (movies, TV shows, music) | 8096 | SMB mount from NAS |
| **Jellyseerr** | CT 114 | Media request management for Jellyfin | 5055 | - |
| **Paperless-NGX** | CT 115 | Document management and OCR | 8000 | SMB mount from NAS |
| **Immich** | CT 130 | Photo management with ML features (testing) | 2283 | SMB mount from NAS |

**Storage**: Media files stored on NAS Node, mounted via SMB to containers.

---

### Download Automation

Usenet/torrent automation for media acquisition.

| Service | Container | Purpose | Web UI Port | Notes |
|---------|-----------|---------|-------------|-------|
| **SABnzbd** | CT 109 | Usenet downloader | 8080 | Downloads to NAS |
| **Sonarr** | CT 110 | TV show automation and management | 8989 | Instance 1 |
| **Sonarr** | CT 111 | Second Sonarr instance for separate libraries | 8989 | Instance 2 |
| **Radarr** | CT 112 | Movie automation and management | 7878 | - |

**Workflow**:
1. User adds media to Sonarr/Radarr
2. Sonarr/Radarr searches indexers
3. Sends download to SABnzbd
4. SABnzbd downloads and extracts to NAS
5. Sonarr/Radarr imports to Jellyfin library
6. Jellyfin scans and makes available

---

### Monitoring & Observability

System monitoring, uptime tracking, and alerting.

| Service | Location | Purpose | Web UI Port | Type |
|---------|----------|---------|-------------|------|
| **Netdata** | Main Node Host | Real-time system monitoring (CPU, RAM, disk, network) | 19999 | Host-level |
| **Netdata** | GPU Node Host | Real-time monitoring for GPU node | 19999 | Host-level |
| **Uptime Kuma** | CT 127 | Uptime monitoring and status page for all services | 3001 | Container |
| **Patchmon** | CT 122 | System update tracking and patch management | - | Container |

**Monitoring Stack Evolution**:
- **Previous** (until 2026-01-08): Prometheus + Grafana + PVE Exporter + InfluxDB
- **Current**: Netdata + Uptime Kuma + Patchmon (simpler, lower resource usage)

**Why the change?**:
- Prometheus/Grafana stack required ~1.5GB RAM
- Netdata provides real-time monitoring with zero configuration
- Uptime Kuma provides simple uptime tracking and status pages
- Reduced complexity and resource usage

---

### Security & Password Management

Security-focused services and credential storage.

| Service | Container | Purpose | Web UI Port | Notes |
|---------|-----------|---------|-------------|-------|
| **Vaultwarden** | CT 104 | Self-hosted password manager (Bitwarden compatible) | 80 | Critical - use HTTPS via proxy |

**Security Considerations**:
- Vaultwarden stores all passwords and secrets
- **Must** be accessed via HTTPS (configure in Nginx Proxy Manager)
- Regular backups essential
- Consider 2FA for admin accounts

---

### Workflow Automation

Automation and orchestration services.

| Service | Container | Purpose | Web UI Port | Notes |
|---------|-----------|---------|-------------|-------|
| **n8n** | CT 125 | Workflow automation (alternative to Zapier/IFTTT) | 5678 | Migrated from GPU Node |
| **Notifiarr** | CT 107 | Notification aggregation and Discord integration | - | For *arr stack |

**n8n Use Cases**:
- Automated notifications
- Data synchronization between services
- Custom webhooks and API integrations
- Scheduled tasks

---

### Dashboard

Centralized access to all services.

| Service | Container | Purpose | Web UI Port |
|---------|-----------|---------|-------------|
| **Homarr** | CT 105 | Service dashboard with quick links and widgets | 7575 |

**Homarr Features**:
- Quick access to all services
- Status widgets (weather, calendar, etc.)
- Customizable layout
- Integration with *arr services for activity display

---

### Support Services

Backend services supporting other applications.

| Service | Container | Purpose | Notes |
|---------|-----------|---------|-------|
| **Redis** | CT 123 | In-memory cache/database | Used by Paperless-NGX and other services |
| **Twitchminer** | CT 100 | Twitch channel points farming | Optional/experimental |

---

### Stopped/Inactive Services

| Service | Container | Purpose | Status |
|---------|-----------|---------|--------|
| **AMPserver** | CT 124 | Game server management panel | Stopped (not currently used) |
| **Ubuntu-test** | GPU CT 102 | Testing container | Stopped |
| **Kubernetes** | GPU CT 103 | Kubernetes testing | Stopped |

---

## Service Dependencies

### Critical Service Chain

```
Internet
   │
   ├─> Pi-hole (DNS) ← All clients use for DNS
   │
   ├─> Nginx Proxy Manager ← Reverse proxy for all web services
   │
   ├─> Cloudflared ← External access
   │
   └─> All other services
```

**If Pi-hole fails**: Use Gateway as fallback DNS, services remain accessible via IP

**If Nginx Proxy Manager fails**: Services accessible via direct IP:PORT, but no domain names

**If Cloudflared fails**: External access unavailable, local access unaffected

### Automation Chain

```
Sonarr/Radarr → SABnzbd → NAS Storage → Jellyfin
       │
       └─> Notifiarr (notifications)
```

### Home Automation Chain

```
Zigbee Devices → ConBee III USB → Zigbee2MQTT → MQTT Broker → Home Assistant / n8n
```

---

## Storage Architecture

### Container Storage

**Location**: Proxmox VE local storage (NVMe SSD on Main Node)
- Containers use thin-provisioned disk images
- OS and application data stored here

### Media Storage

**Location**: NAS Node (OpenMediaVault)
- 2x 16TB HDDs in enclosure
- Filesystem: EXT4
- Access: SMB shares mounted via fstab on Main Node
- Mounted to media containers (Jellyfin, SABnzbd, Radarr, Sonarr)

**SMB Mount Example** (configured in Proxmox host):
```bash
# /etc/fstab on Main Node
//NAS_NODE_IP/media /mnt/nas/media cifs credentials=/etc/smbcredentials,uid=100000,gid=100000 0 0
```

**Bind Mounts** (container config):
- Jellyfin: `/mnt/nas/media` → `/media` (read-only)
- SABnzbd: `/mnt/nas/downloads` → `/downloads` (read-write)
- Radarr/Sonarr: `/mnt/nas/media` → `/media` (read-write)

---

## Backup Strategy

### What Gets Backed Up

**Proxmox Backup Server** (on Backup Node) backs up:
- All running containers (daily snapshots)
- Container configurations
- Proxmox VE configuration

**Schedule**:
- VMs: Daily at 02:00
- Containers: Daily at 03:00
- Retention: 7 daily, 4 weekly, 6 monthly

### What Doesn't Get Backed Up (Yet)

- NAS media files (too large for PBS)
- Container volumes with large data (e.g., Immich photos)

**Planned**: External HDD for NAS data backup (manual/rsync)

---

## Service Deployment

### Using Proxmox Community Scripts

Many containers deployed using helper scripts from [community-scripts.github.io/ProxmoxVE](https://community-scripts.github.io/ProxmoxVE/).

**Example - Deploying Jellyfin**:
```bash
# Run in Proxmox VE shell
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/jellyfin.sh)"
```

**Post-deployment**:
1. Configure network (DHCP or static IP)
2. Add DNS entry in Pi-hole
3. Configure reverse proxy in Nginx Proxy Manager
4. Mount NAS storage if needed
5. Add to Uptime Kuma monitoring
6. Document in this file

### Manual Container Creation

For services without community scripts:

1. Create LXC container in Proxmox (Debian 12 template)
2. Allocate resources (RAM, CPU, disk)
3. Configure network settings
4. Install service via apt/docker/manual
5. Configure service
6. Set up autostart and monitoring

---

## External Access Configuration

### Cloudflare Tunnel Setup

**How it works**:
1. Cloudflared container connects to Cloudflare
2. No inbound ports opened on router
3. Services exposed via Cloudflare domains
4. Encrypted end-to-end

**Configuration** (in cloudflared container):
```yaml
# /etc/cloudflared/config.yml
tunnel: YOUR_TUNNEL_ID
credentials-file: /root/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: vaultwarden.yourdomain.com
    service: http://VAULTWARDEN_IP:80
  - hostname: jellyfin.yourdomain.com
    service: http://JELLYFIN_IP:8096
  - service: http_status:404  # Catch-all
```

**Services Exposed**:
- Vaultwarden (password manager)
- Jellyfin (media streaming)
- Others as needed

**Security**: Each service should have authentication enabled (passwords, SSO, etc.)

---

## Resource Usage

### Container Resource Allocation

Most containers use default allocations from community scripts:
- **Small services** (Redis, MQTT): 512MB RAM, 1 CPU core, 2-4GB disk
- **Medium services** (Jellyfin, *arr stack): 1-2GB RAM, 2 CPU cores, 8-16GB disk
- **Large services** (Immich): 4-8GB RAM, 4 CPU cores, 20-50GB disk

**Main Node Total**: ~32GB RAM available
- Proxmox host: ~4GB
- 23 containers: ~16-20GB
- Remaining: ~8-12GB buffer

### Monitoring Resource Usage

**Via Netdata**:
- Per-container CPU, RAM, disk I/O
- Network traffic per container
- Real-time graphs and historical data

**Via Proxmox UI**:
- Summary view of all containers
- Resource graphs per container

---

## Service URLs Quick Reference

| Service | Internal URL | External URL |
|---------|--------------|--------------|
| **Proxmox VE** | `https://MAIN_NODE_IP:8006` | - |
| **Pi-hole** | `http://PRIMARY_DNS_IP/admin` | - |
| **Nginx Proxy Manager** | `http://NGINX_IP:81` | - |
| **Vaultwarden** | `http://VAULTWARDEN_IP` | `https://vault.yourdomain.com` |
| **Homarr** | `http://HOMARR_IP:7575` | - |
| **Jellyfin** | `http://JELLYFIN_IP:8096` | `https://jellyfin.yourdomain.com` |
| **Netdata (Main)** | `http://MAIN_NODE_IP:19999` | - |
| **Uptime Kuma** | `http://UPTIME_KUMA_IP:3001` | - |
| **n8n** | `http://N8N_IP:5678` | - |

**Note**: Replace placeholder IPs with your actual container IPs.

---

## Troubleshooting Common Issues

### Container Won't Start

**Check**:
1. Proxmox logs: `pct enter <CTID>` or `journalctl -xe`
2. Storage availability: `df -h`
3. Resource limits: Check RAM/CPU allocation in Proxmox
4. Network configuration: Ensure DHCP or static IP configured

### Service Not Accessible

**Check**:
1. Service running: `systemctl status <service>` (inside container)
2. Port correct: Check service documentation for default port
3. Firewall: Container firewall may block ports
4. DNS: Verify Pi-hole has correct entry
5. Reverse proxy: Check Nginx Proxy Manager configuration

### High Resource Usage

**Check**:
1. Netdata: Identify which container is using resources
2. Logs: Check for errors causing loops
3. Recent changes: Did configuration change break something?
4. Restart: Sometimes resolves transient issues

---

## Future Service Ideas

**Potential additions** (not yet implemented):

- **Authelia**: SSO and 2FA for all services
- **Nextcloud**: File sync and collaboration
- **Wikijs**: Documentation wiki
- **Tandoor**: Recipe management
- **FreshRSS**: RSS feed aggregator
- **Audiobookshelf**: Audiobook and podcast server

---

## References

- **Proxmox Community Scripts**: https://community-scripts.github.io/ProxmoxVE/
- **Awesome-Selfhosted**: https://github.com/awesome-selfhosted/awesome-selfhosted
- **r/selfhosted**: https://reddit.com/r/selfhosted

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-09 | Initial public services documentation created |

---

**Note**: This is a template document with placeholders. Replace all `PLACEHOLDER_VALUES` with your actual service IPs and configurations before deployment.
