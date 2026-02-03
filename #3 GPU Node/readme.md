# GPU Node Configuration Guide

Comprehensive guide for the GPU Node - an on-demand Proxmox VE server with GPU passthrough capability.

**Status**: Public documentation with placeholders for sensitive information

## Table of Contents
- [Overview](#overview)
- [Hardware Specifications](#hardware-specifications)
- [Proxmox VE Installation](#proxmox-ve-installation)
- [GPU Passthrough Configuration](#gpu-passthrough-configuration)
- [Wake-on-LAN Setup](#wake-on-lan-setup)
- [LXC Containers](#lxc-containers)
- [Power Management](#power-management)
- [Troubleshooting](#troubleshooting)
- [Related Files](#related-files)

---

## Overview

The GPU Node is configured to run **on-demand** using Wake-on-LAN (WOL) to minimize power consumption when GPU acceleration is not needed.

**Purpose**:
- GPU-accelerated workloads (AI/ML, transcoding, rendering)
- On-demand compute tasks
- Testing and development
- Reduced power consumption (~100-150W only when in use)

**Key Features:**
- AMD Ryzen 5 5600G CPU with integrated graphics
- Nvidia P2000 GPU with passthrough capability
- 32GB RAM for memory-intensive workloads
- Proxmox VE as hypervisor
- Wake-on-LAN for remote power management

**Operating Mode**: On-demand (not 24/7) - powered on only when needed to save energy.

---

## Hardware Specifications

| Component | Specification | Notes |
|-----------|---------------|-------|
| **CPU** | AMD Ryzen 5 5600G | 6 cores, 12 threads, integrated Vega graphics |
| **RAM** | 32GB DDR4 | Sufficient for multiple VMs or containers |
| **GPU** | Nvidia P2000 | 5GB GDDR5, suitable for compute/transcoding |
| **Storage** | NVMe SSD (size varies) | Fast storage for VMs and containers |
| **Network** | Gigabit Ethernet | WOL-capable network interface |
| **Power** | ~100-150W idle | ~200W under load |
| **Form Factor** | Desktop/Tower | Custom build |

**Network Configuration**:
- **Interface**: enp3s0
- **IP**: `GPU_NODE_IP` (static recommended)
- **MAC**: `GPU_NODE_MAC` (required for WOL)
- **Gateway**: `GATEWAY_IP`
- **DNS**: `PRIMARY_DNS_IP` (Pi-hole)

---

## Proxmox VE Installation

### Initial Setup

1. **Download Proxmox VE ISO**:
   - Visit: https://www.proxmox.com/en/downloads
   - Download latest Proxmox VE ISO installer

2. **Create Bootable USB**:
   ```bash
   # On Linux
   dd if=proxmox-ve_*.iso of=/dev/sdX bs=1M status=progress

   # Or use Etcher/Rufus on Windows
   ```

3. **Boot from USB and Install**:
   - Select "Install Proxmox VE"
   - Configure disk (use entire disk or ZFS if multiple disks)
   - Set timezone and keyboard layout
   - Configure network:
     - **Hostname**: `pve` or `gpu-node`
     - **IP**: `GPU_NODE_IP`
     - **Netmask**: `255.255.255.0` (for /24 network)
     - **Gateway**: `GATEWAY_IP`
     - **DNS**: `PRIMARY_DNS_IP`
   - Set root password (store in password manager)
   - Complete installation and reboot

4. **Post-Installation Configuration**:
   ```bash
   # Update system
   apt update && apt full-upgrade -y

   # Remove subscription nag (optional, for non-enterprise use)
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
   apt update

   # Install useful tools
   apt install -y ethtool wakeonlan vim htop
   ```

5. **Access Web UI**:
   - Navigate to: `https://GPU_NODE_IP:8006`
   - Login: `root` / (password set during installation)

---

## GPU Passthrough Configuration

### Enable IOMMU in BIOS

1. Reboot and enter BIOS/UEFI settings
2. Enable:
   - **AMD-Vi** or **IOMMU** (for AMD CPUs)
   - **VT-d** (for Intel CPUs)
3. Save and exit

### Configure Proxmox for GPU Passthrough

**1. Enable IOMMU in GRUB**:
```bash
# Edit GRUB configuration
nano /etc/default/grub

# For AMD CPUs, add to GRUB_CMDLINE_LINUX_DEFAULT:
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"

# For Intel CPUs, use:
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"

# Update GRUB
update-grub
```

**2. Load VFIO modules**:
```bash
# Add modules to load at boot
nano /etc/modules

# Add these lines:
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd

# Update initramfs
update-initramfs -u -k all
```

**3. Blacklist GPU drivers on host**:
```bash
# Prevent host from loading Nvidia/AMD drivers
nano /etc/modprobe.d/blacklist.conf

# For Nvidia GPU:
blacklist nouveau
blacklist nvidia

# For AMD GPU:
# blacklist radeon
# blacklist amdgpu

# Update initramfs
update-initramfs -u -k all
```

**4. Bind GPU to VFIO**:
```bash
# Find GPU vendor:device ID
lspci -nn | grep -i nvidia
# Output example: 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP106GL [Quadro P2000] [10de:1c30]
# Note the vendor:device ID: 10de:1c30

# Add to VFIO configuration
nano /etc/modprobe.d/vfio.conf

# Add line (replace with your GPU IDs):
options vfio-pci ids=10de:1c30,10de:10f1

# Update initramfs
update-initramfs -u -k all
```

**5. Reboot**:
```bash
reboot
```

**6. Verify IOMMU and VFIO**:
```bash
# Check IOMMU groups
find /sys/kernel/iommu_groups/ -type l

# Verify GPU bound to vfio-pci
lspci -nnk | grep -i nvidia -A 3
# Should show: Kernel driver in use: vfio-pci
```

### Passthrough GPU to VM

**When creating or editing a VM**:
1. **Hardware** → **Add** → **PCI Device**
2. Select the GPU (should show as vfio device)
3. Enable:
   - **All Functions** (if GPU has audio device)
   - **Primary GPU** (if using for display output)
   - **PCI-Express** (recommended)

**VM Configuration**:
- **Machine**: q35
- **BIOS**: OVMF (UEFI) - required for GPU passthrough
- **Display**: None or VirtIO-GPU (for console access)

---

## Wake-on-LAN Setup

### Enable WOL in BIOS

1. Boot into BIOS/UEFI settings
2. Navigate to **Power Management** or **Advanced**
3. Enable:
   - **Wake-on-LAN**
   - **Power on by PCI-E/PCI**
   - **Resume by PCI or PCI-E Device**
4. Save and exit

### Configure Network Interface for WOL

**On the GPU Node** (in Proxmox):
```bash
# Check current WOL status
ethtool enp3s0 | grep Wake-on
# Should show: Wake-on: d (disabled) or g (enabled)

# Enable WOL (g = Magic Packet)
ethtool -s enp3s0 wol g

# Verify
ethtool enp3s0 | grep Wake-on
# Should show: Wake-on: g

# Make persistent (add to cron or systemd)
crontab -e
# Add line:
@reboot /usr/sbin/ethtool -s enp3s0 wol g
```

**Alternative - systemd service**:
```bash
# Create systemd service
nano /etc/systemd/system/wol.service

# Add content:
[Unit]
Description=Enable Wake-on-LAN on enp3s0
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ethtool -s enp3s0 wol g

[Install]
WantedBy=multi-user.target

# Enable service
systemctl enable wol.service
systemctl start wol.service
```

### Wake-on-LAN Script

**Create the script on Main Node or any network device**:

See [wake-on-lan.sh](wake-on-lan.sh) for the template script.

**Usage**:
```bash
# Make executable
chmod +x wake-on-lan.sh

# Wake GPU Node
./wake-on-lan.sh
```

**From Main Node** (for automated tasks):
```bash
wakeonlan -i BROADCAST_IP GPU_NODE_MAC
```

---

## LXC Containers

### Current Containers

| CT ID | Service | Purpose | Status |
|-------|---------|---------|--------|
| **CT 100** | Netbird | VPN mesh network | Running |
| **CT 102** | ubuntu-test | Testing container | Stopped |
| **CT 103** | kubernetes | Kubernetes testing | Stopped |

**Note**: CT 108 (n8n) was migrated to Main Node CT 125.

### Container Management

**Start a container**:
```bash
pct start <CTID>
```

**Stop a container**:
```bash
pct stop <CTID>
```

**Enter container console**:
```bash
pct enter <CTID>
```

**View container config**:
```bash
pct config <CTID>
```

---

## Power Management

### Power Consumption

| State | Power Draw | Annual Cost (0.30 €/kWh) |
|-------|------------|--------------------------|
| **Off** | 0W | 0 € |
| **Idle** | ~100-150W | ~260-390 € (if 24/7) |
| **Load** | ~200W | ~525 € (if 24/7) |
| **On-Demand** (8h/week) | ~100W avg | ~12.5 € (actual usage) |

**Savings**: Running on-demand vs 24/7 saves ~250-380 €/year.

### Shutdown Strategies

**Manual shutdown**:
```bash
# Via web UI: Shutdown button

# Via SSH:
shutdown -h now
```

**Automated shutdown** (from Main Node):
```bash
# After completing task
ssh root@GPU_NODE_IP "shutdown -h now"
```

**Scheduled shutdown** (if used for specific tasks):
```cron
# Shutdown at 22:00 if no VMs/containers running
0 22 * * * [ $(qm list | grep -c running) -eq 0 ] && shutdown -h now
```

---

## Monitoring

### Netdata Installation

**Install Netdata on GPU Node**:
```bash
# Install
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Access
# http://GPU_NODE_IP:19999
```

**Features**:
- Real-time CPU, RAM, disk, network monitoring
- GPU monitoring (with nvidia-smi plugin)
- Per-container resource usage

### Uptime Kuma Monitoring

Add GPU Node to Uptime Kuma (CT 127 on Main Node):
- **Type**: Ping
- **Host**: `GPU_NODE_IP`
- **Interval**: 60 seconds (when node is expected to be online)

---

## Troubleshooting

### GPU Passthrough Not Working

**Check IOMMU enabled**:
```bash
dmesg | grep -i iommu
# Should show IOMMU enabled messages
```

**Verify GPU bound to vfio-pci**:
```bash
lspci -nnk | grep -i nvidia -A 3
# Should show: Kernel driver in use: vfio-pci
```

**Check IOMMU groups**:
```bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s ' "$n"
  lspci -nns "${d##*/}"
done
```

### WOL Not Working

**Check WOL enabled in OS**:
```bash
ethtool enp3s0 | grep Wake-on
# Should show: g
```

**Test from another machine**:
```bash
# Install wakeonlan
apt install wakeonlan

# Send magic packet
wakeonlan -i BROADCAST_IP GPU_NODE_MAC

# Check if node responds (wait 30-60 seconds)
ping GPU_NODE_IP
```

**Common issues**:
- WOL disabled in BIOS
- Network interface powered down completely
- Wrong MAC address in WOL command
- Firewall blocking UDP port 9 (magic packet)

### High Power Consumption

**Check running VMs/containers**:
```bash
qm list  # VMs
pct list # Containers
```

**Stop unnecessary services**:
```bash
pct stop <CTID>
qm stop <VMID>
```

**Shutdown if idle**:
```bash
shutdown -h now
```

---

## Use Cases

### When to Use GPU Node

**Ideal for**:
- Video transcoding (Jellyfin GPU acceleration)
- AI/ML model training or inference
- Game server hosting (GPU-required games)
- 3D rendering
- GPU-accelerated encoding/decoding
- Development/testing with GPU

**Not ideal for**:
- 24/7 services (use Main Node instead)
- Services that don't benefit from GPU
- Low-latency always-available services

### Example Workloads

**Jellyfin with GPU transcoding**:
- Transcode 4K → 1080p streams
- Hardware acceleration reduces CPU load
- Power on when watching media, shutdown after

**AI/ML with TensorFlow/PyTorch**:
- Train models with CUDA acceleration
- Run inference on GPU
- Use on-demand when experimenting

---

## Future Enhancements

**Potential additions**:
- Automated startup/shutdown based on usage detection
- GPU metrics in monitoring dashboard
- Additional containers for GPU workloads
- VM templates for GPU-accelerated tasks

---

## Related Files

| File | Description |
|------|-------------|
| [wake-on-lan.sh](wake-on-lan.sh) | Wake-on-LAN script template for GPU Node |
| readme.md | This comprehensive configuration guide |

---

## References

- **Proxmox GPU Passthrough**: https://pve.proxmox.com/wiki/PCI_Passthrough
- **Proxmox VE Documentation**: https://pve.proxmox.com/pve-docs/
- **Wake-on-LAN Guide**: https://wiki.archlinux.org/title/Wake-on-LAN
- **Nvidia P2000 Specs**: https://www.nvidia.com/en-us/design-visualization/quadro/p2000/

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-09 | Expanded documentation with Proxmox setup, GPU passthrough, containers, troubleshooting |
| (Earlier) | Initial WOL setup guide |

---

**Note**: This is a public documentation template with placeholders. Replace all `PLACEHOLDER_VALUES` with your actual network configuration before deployment.
