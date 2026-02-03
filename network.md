# Network Configuration

Documentation of the homelab network topology and configuration.

**Status**: Public documentation with placeholders for sensitive information

---

## Network Overview

### Topology Type

**Flat Network** - All devices in the same network segment
- **Network**: `192.168.X.0/24` (use your preferred network)
- **No VLANs** - Simplified management, all devices trusted
- **Star Topology** - All nodes connected directly to gateway

### Network Architecture Diagram

```
                        [Internet]
                            │
                            │ ISP Connection
                            │
                            ▼
                     ┌──────────────┐
                     │   Gateway    │
                     │  GATEWAY_IP  │
                     │  Router      │
                     │  DHCP Server │
                     │  DNS (2nd)   │
                     └──────┬───────┘
                            │
             ┌──────────────┼──────────────┬──────────────┐
             │              │              │              │
             ▼              ▼              ▼              ▼
      ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐
      │ Main Node  │ │  NAS Node  │ │  GPU Node  │ │Backup Node │
      │MAIN_NODE_IP│ │ NAS_NODE_IP│ │ GPU_NODE_IP│ │BACKUP_NODE │
      │            │ │            │ │            │ │    _IP     │
      │  Proxmox   │ │    OMV     │ │  Proxmox   │ │    PBS     │
      │   (24/7)   │ │   (24/7)   │ │ (On-Demand)│ │(On-Demand) │
      └────────────┘ └────────────┘ └────────────┘ └────────────┘
             │              │              │              │
             │              │              └──────────────┘
             │              │                      │
             │              │               (Wake-on-LAN)
             │              │
             └──────────────┴──────────────────────┘
                            │
                    LXC Containers (Main Node):
                 23+ containers providing services
                 - Infrastructure (DNS, Proxy, VPN)
                 - Home Automation (MQTT, Zigbee)
                 - Media (Jellyfin, Immich)
                 - Monitoring (Netdata, Uptime Kuma)
                 - Security (Vaultwarden)
```

---

## IP Address Allocation

### Network Ranges

| Range | Purpose | Example IPs |
|-------|---------|-------------|
| `.1` | Gateway/Router | `GATEWAY_IP` |
| `.2-.99` | Static assignments (servers, containers) | Node IPs, critical services |
| `.100-.200` | DHCP range (clients, non-critical containers) | Desktops, phones, test containers |
| `.201-.254` | Reserved for future use | Expansion |

### Server Node IPs (Static)

| Node | IP | MAC | Interface | Notes |
|------|-------|-----|-----------|-------|
| **Main Node** | `MAIN_NODE_IP` | `XX:XX:XX:XX:XX:XX` | eth0/enp1s0 | 24/7 Proxmox VE host |
| **NAS Node** | `NAS_NODE_IP` | `XX:XX:XX:XX:XX:XX` | enp2s0 | 24/7 OpenMediaVault |
| **GPU Node** | `GPU_NODE_IP` | `GPU_NODE_MAC` | enp3s0 | On-demand Proxmox VE, WOL enabled |
| **Backup Node** | `BACKUP_NODE_IP` | `BACKUP_NODE_MAC` | enp2s0 | On-demand PBS, WOL enabled |

### Critical Container IPs (Static Recommended)

| Container | Service | IP | Notes |
|-----------|---------|-------|-------|
| **CT 108** | Pi-hole (DNS) | `PRIMARY_DNS_IP` | Primary DNS server - **must be static** |
| **CT 106** | Nginx Proxy Manager | `NGINX_IP` | Reverse proxy - static recommended |
| **CT 101** | Cloudflared | `CLOUDFLARED_IP` | Tunnel - static recommended |

**Recommendation**: Set DHCP reservations or static IPs for all infrastructure containers (DNS, proxy, VPN) to ensure stability.

---

## Physical Cabling

### Node Connections

| Node | Interface | Cable Type | Connected To | Speed |
|------|-----------|------------|--------------|-------|
| Main Node | eth0 | Cat 6 | Gateway LAN Port 1 | 1 Gbps |
| NAS Node | enp2s0 | Cat 6 | Gateway LAN Port 2 | 1 Gbps |
| GPU Node | enp3s0 | Cat 6 | Gateway LAN Port 3 | 1 Gbps |
| Backup Node | enp2s0 | Cat 6 | Gateway LAN Port 4 | 1 Gbps |

**Topology**: Star topology - all nodes directly connected to gateway

**Cable Management**:
- Use labeled cables for easy identification
- Keep cables organized and secured
- Leave slack for maintenance

---

## DNS Configuration

### DNS Hierarchy

```
                     [Client Device]
                            │
                            │ DNS Request
                            ▼
                      ┌──────────┐
                      │ Pi-hole  │
                      │PRIMARY_  │ ← Primary DNS (ad blocking)
                      │DNS_IP    │
                      └────┬─────┘
                           │
                           │ Not in Cache/Blocklist?
                           ▼
                     ┌──────────┐
                     │ Gateway  │
                     │GATEWAY_IP│ ← Secondary DNS (fallback)
                     └────┬─────┘
                          │
                          │ Forward to ISP/Public DNS
                          ▼
                   [Public DNS: 1.1.1.1, 8.8.8.8]
```

### DNS Server Setup

**Primary DNS** (Pi-hole in CT 108):
- **IP**: `PRIMARY_DNS_IP`
- **Purpose**: Ad-blocking, local DNS resolution
- **Upstream DNS**: Gateway or public DNS (Cloudflare, Google)
- **Admin Interface**: `http://PRIMARY_DNS_IP/admin`

**Secondary DNS** (Gateway):
- **IP**: `GATEWAY_IP`
- **Purpose**: Fallback when Pi-hole unavailable
- **Type**: Router's built-in DNS

### DHCP Configuration

**DHCP Server**: Gateway router

**Settings**:
- **DHCP Range**: `.100-.200`
- **Lease Time**: 24 hours (default)
- **Gateway**: `GATEWAY_IP`
- **Primary DNS**: `PRIMARY_DNS_IP` (Pi-hole)
- **Secondary DNS**: `GATEWAY_IP` (Gateway fallback)

**DHCP Reservations** (recommended):
Configure in router for critical services:
- Pi-hole (CT 108): `PRIMARY_DNS_IP`
- Nginx Proxy Manager (CT 106): `NGINX_IP`
- Cloudflared (CT 101): `CLOUDFLARED_IP`

---

## Wake-on-LAN Configuration

### Enabling WOL

**On each node that should support WOL** (GPU Node, Backup Node):

1. **Enable in BIOS**:
   - Boot into BIOS/UEFI settings
   - Navigate to Power Management
   - Enable "Wake-on-LAN" or "Power on by PCI-E/PCI"
   - Save and exit

2. **Configure network interface** (Linux):
   ```bash
   # Check current WOL status
   ethtool <interface> | grep Wake-on

   # Enable WOL (g = Magic Packet)
   ethtool -s <interface> wol g

   # Make persistent (add to cron or systemd)
   echo "ethtool -s <interface> wol g" >> /etc/rc.local
   ```

3. **Test WOL from another machine**:
   ```bash
   # Install wakeonlan package
   apt install wakeonlan -y

   # Wake target node
   wakeonlan -i BROADCAST_IP TARGET_NODE_MAC
   ```

### WOL Usage Examples

**Wake GPU Node**:
```bash
wakeonlan -i BROADCAST_IP GPU_NODE_MAC
```

**Wake Backup Node**:
```bash
wakeonlan -i BROADCAST_IP BACKUP_NODE_MAC
```

**Automated WOL** (cron on Main Node):
```cron
# Wake Backup Node every Sunday at 00:30
30 0 * * 0 /usr/bin/wakeonlan BACKUP_NODE_MAC

# Shutdown Backup Node every Sunday at 06:00
0 6 * * 0 ssh root@BACKUP_NODE_IP "shutdown -h now"
```

**Requirements for automated shutdown**:
- SSH key authentication from Main Node to target node
- No password prompt required

---

## Network Services

### Infrastructure Services

| Service | Container | IP | Port | Purpose |
|---------|-----------|-------|------|---------|
| **Pi-hole** | CT 108 | `PRIMARY_DNS_IP` | 80, 53 | DNS + Ad-blocking |
| **Nginx Proxy Manager** | CT 106 | `NGINX_IP` | 80, 443, 81 | Reverse proxy |
| **Cloudflared** | CT 101 | `CLOUDFLARED_IP` | - | Secure tunnel |
| **Netbird** | CT 121 | DHCP | - | VPN mesh network |

### Home Automation

| Service | Container | IP | Port | Purpose |
|---------|-----------|-------|------|---------|
| **MQTT** | CT 102 | DHCP | 1883 | Message broker |
| **Zigbee2MQTT** | CT 103 | DHCP | 8080 | Zigbee integration |

### Monitoring

| Service | Location | IP | Port | Purpose |
|---------|----------|-------|------|---------|
| **Netdata** | Main Node Host | `MAIN_NODE_IP` | 19999 | Real-time monitoring |
| **Netdata** | GPU Node Host | `GPU_NODE_IP` | 19999 | GPU node monitoring |
| **Uptime Kuma** | CT 127 | DHCP | 3001 | Uptime monitoring |

---

## Firewall & Security

### Current Configuration

**Firewall**: Gateway router's built-in firewall (default: enabled)

**Inbound Rules**:
- All inbound connections blocked by default
- No port forwarding configured (external access via Cloudflare Tunnel)

**Outbound Rules**:
- All outbound connections allowed

### External Access Strategy

**Method**: Cloudflare Tunnel (via Cloudflared in CT 101)
- **Advantages**: No port forwarding, encrypted, DDoS protection
- **How it works**: Services exposed through Cloudflare without opening router ports
- **Use case**: Secure access to Vaultwarden, Jellyfin, etc. from internet

**No direct port forwarding** to maintain security.

### Internal Network Security

**Current State**: Flat network (no segmentation)
- All devices on same subnet trust each other
- No VLAN segmentation implemented
- Simplified for home use

**Future Considerations** (optional):
- VLAN segmentation (IoT, servers, clients)
- Internal firewall rules
- Network access control lists

---

## Network Monitoring

### Monitoring Tools

**Netdata** (installed on Proxmox hosts):
- Real-time network traffic monitoring
- Interface statistics (bandwidth, packets, errors)
- Per-container network usage

**Uptime Kuma** (CT 127):
- Service availability monitoring
- Ping monitoring for all nodes
- HTTP/HTTPS checks for web services

### Key Metrics to Monitor

- **Bandwidth usage**: Main Node ↔ NAS (SMB traffic)
- **Latency**: All nodes to gateway (<1ms expected)
- **Packet loss**: Should be 0% on wired connections
- **Service uptime**: DNS (Pi-hole), Proxy (Nginx)

---

## Troubleshooting

### Common Network Issues

**DNS not resolving**:
1. Check Pi-hole status: `systemctl status pihole-FTL`
2. Test DNS directly: `nslookup google.com PRIMARY_DNS_IP`
3. Check gateway DNS as fallback: `nslookup google.com GATEWAY_IP`
4. Verify DHCP is distributing correct DNS servers

**Container can't reach internet**:
1. Check gateway: `ping GATEWAY_IP` (from container)
2. Check DNS: `ping 8.8.8.8` (if works, DNS issue)
3. Check routing: `ip route` (verify default route)
4. Check Proxmox firewall rules

**WOL not working**:
1. Verify WOL enabled in BIOS
2. Check interface setting: `ethtool <interface> | grep Wake-on`
3. Ensure magic packet reaches node (no firewall blocking)
4. Verify MAC address in WOL command

**Slow SMB transfers (NAS to Main Node)**:
1. Check network speed: `iperf3` between nodes (should be ~940 Mbps)
2. Verify Cat 6 cables used (not Cat 5)
3. Check NAS disk performance: `hdparm -t /dev/sdX`
4. Check SMB version: `smbstatus` (SMBv3 preferred)

---

## Network Expansion

### Adding New Devices

**For new servers/nodes**:
1. Assign static IP from `.2-.99` range
2. Document MAC address
3. Configure in gateway if DHCP reservation needed
4. Add to monitoring (Uptime Kuma)
5. Update this documentation

**For new containers**:
1. Let DHCP assign IP initially (`.100-.200`)
2. If critical service, set DHCP reservation or static IP
3. Document container ID and purpose
4. Add to Nginx Proxy Manager if needs web access
5. Add to monitoring if required

---

## Network Backup

### Configuration Backup

**Router configuration**:
- Export settings regularly (gateway web interface)
- Store encrypted in password manager or secure location

**Pi-hole configuration**:
- Settings → Teleporter (exports all settings)
- Backup gravity database: `/etc/pihole/`

**Network documentation**:
- This file and related documentation in version control
- Keep up-to-date as network changes

---

## References

- **Proxmox VE Network Configuration**: https://pve.proxmox.com/wiki/Network_Configuration
- **Pi-hole Documentation**: https://docs.pi-hole.net/
- **Wake-on-LAN Guide**: https://wiki.archlinux.org/title/Wake-on-LAN
- **OpenMediaVault Networking**: https://docs.openmediavault.org/

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-09 | Initial public network documentation created with placeholders |

---

**Note**: This is a template document with placeholders. Replace all `PLACEHOLDER_VALUES` with your actual network configuration before deployment.
