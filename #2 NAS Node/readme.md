# NAS Node Configuration Guide

## Table of Contents
- [TrueNAS Scale Setup (Initial Attempt)](#truenas-scale-setup-initial-attempt)
  - [Installation](#installation)
  - [Storage Configuration](#storage-configuration)
  - [SMB Share Setup](#smb-share-setup)
  - [Proxmox Integration](#proxmox-integration)
  - [Why TrueNAS Was Replaced](#why-truenas-was-replaced)
- [OpenMediaVault Setup (Current Solution)](#openmediavault-setup-current-solution)
  - [Installation](#installation-1)
  - [Initial Configuration](#initial-configuration)
  - [User Management](#user-management)
  - [File System Setup](#file-system-setup)
  - [SMB Configuration](#smb-configuration)
  - [Proxmox Integration via fstab](#proxmox-integration-via-fstab)
- [Current Proxmox Storage Overview](#current-proxmox-storage-overview)
- [Known Issues](#known-issues)

---

## TrueNAS Scale Setup (Initial Attempt)

### Installation

**Steps:**
1. Downloaded TrueNAS Scale image
2. Created bootable USB stick using imaging tool
3. Installed TrueNAS Scale on the NAS Node
4. Completed initial login following TrueNAS documentation
5. Created user accounts

### Storage Configuration

**Hardware:**
- **DAS Enclosure**: Connected via USB-C to USB-A adapter
- **Storage Pool**: Created with one disk from the DAS

**Dataset Structure:**
1. Created main dataset
2. Created SMB dataset underneath for network file sharing

### SMB Share Setup

**Configuration:**
- Set up permissions via Share ACL
- Configured SMB share for network access

### Proxmox Integration

**Testing SMB Connectivity:**
```bash
pvesm cifsscan NAS_NODE_IP --username "USERNAME" --password
# Enter Password: **********
# Output: smb
```

**Adding SMB Storage:**
```bash
pvesm add cifs SMB1 --server NAS_NODE_IP --share "smb" --username "USERNAME" --password
```

**Parameters:**
- `SMB1`: Display name in Proxmox
- `--server`: NAS Node IP address
- `--share`: SMB share name
- `--username`: Proxmox user on TrueNAS
- `--password`: User password (prompted)

### Why TrueNAS Was Replaced

**Issue**: TrueNAS uses ZFS automatically, which consumed excessive RAM for this low-power setup.

**Decision**: Switched to OpenMediaVault for lower resource usage.

---

## OpenMediaVault Setup (Current Solution)

### Installation

1. Downloaded OpenMediaVault (OMV) image
2. Installed OMV on the NAS Node
3. Completed initial login following OMV documentation

### Initial Configuration

**Post-Installation Steps:**
1. Ran system updates
2. Changed default password
3. Configured network settings

### User Management

**Created Users:**
- Personal user account
- `proxmox` user for SMB access from Proxmox

### File System Setup

**Initial Attempt:**
- Tried XFS file system with DAS
- ❌ **Failed**: XFS did not work properly via DAS connection

**Current Solution:**
- **File System**: EXT4
- **Status**: ✅ Working

**Configuration:**
1. Navigate to **Storage → File Systems**
2. Create new file system with EXT4
3. Mount the file system

### SMB Configuration

**SMB Share Settings:**
1. Navigate to **Storage → Shared Folders**
2. Create new SMB share
3. **Enable**: "Store DOS attributes"
4. Navigate to **Services → SMB/CIFS → Settings**
5. Set **Minimum protocol** to **SMB1**

### Proxmox Integration via fstab

**Issue**: GUI-based integration (`pvesm add cifs`) did not work with OMV.

**Workaround: Manual fstab Mount**

**1. Create SMB credentials file:**
```bash
# Create credentials file
nano /etc/smbcredentials

# Add the following:
username=YOUR_USERNAME
password=YOUR_PASSWORD
```

**2. Set proper permissions:**
```bash
chmod 600 /etc/smbcredentials
```

**3. Modify fstab:**
```bash
nano /etc/fstab

# Add the following line:
//NAS_NODE_IP/smb /mnt/smb cifs credentials=/etc/smbcredentials,iocharset=utf8,file_mode=0777,dir_mode=0777 0 0
```

**4. Mount the share:**
```bash
mount -a
```

**Status**: ✅ Working via fstab mount

---

## Current Proxmox Storage Overview

| Storage Name | Type                  | Description                    |
|--------------|-----------------------|--------------------------------|
| local        | Local storage         | System storage                 |
| PBS          | Backup server         | Proxmox Backup Server          |
| data2        | Local SSD             | 2 TB M.2 SSD                   |
| SMB1         | Network share         | SMB share from OMV NAS         |

---

## Known Issues

### OMV SMB Integration with Proxmox

**Problem**:
- Proxmox GUI integration does not work with OMV SMB shares
- `pvesm add cifs` command fails

**Current Workaround**:
- Manual mount via `/etc/fstab` with credentials file
- Works reliably but lacks Proxmox GUI management

**Status**:
- ⏸️ **Postponed** - Will revisit for a proper solution later
- Current fstab method is sufficient for now

---

## Notes

- TrueNAS Scale was replaced due to high RAM usage from ZFS
- OpenMediaVault provides a lighter alternative suitable for low-power hardware
- XFS file system did not work with DAS connection; EXT4 is used instead
- Proxmox SMB integration requires manual fstab configuration
- All configurations assume root access on both Proxmox and OMV
