# GPU Node Configuration Guide

## Table of Contents
- [Overview](#overview)
- [Wake-on-LAN Setup](#wake-on-lan-setup)
  - [Script Creation](#script-creation)
  - [Make Script Executable](#make-script-executable)
  - [Usage](#usage)
- [Related Files](#related-files)

---

## Overview

The GPU Node is configured to run **on-demand** using Wake-on-LAN (WOL) to minimize power consumption when not in use.

**Key Features:**
- AMD Ryzen 5 5600G CPU
- Nvidia P2000 GPU with passthrough capability
- Proxmox VE as hypervisor
- Wake-on-LAN for remote power management

---

## Wake-on-LAN Setup

### Script Creation

A Wake-on-LAN script has been generated to remotely power on the GPU Node.

**Create the script:**
```bash
nano ~/wake-server.sh
```

**Script content** can be found in: [wake-on-lan.sh](wake-on-lan.sh)

### Make Script Executable

After creating the script, make it executable:
```bash
chmod +x ~/wake-server.sh
```

### Usage

**Wake up the GPU Node:**
```bash
~/wake-server.sh
```

This will send a Wake-on-LAN magic packet to power on the GPU Node remotely.

---

## Related Files

| File                | Description                          |
|---------------------|--------------------------------------|
| wake-on-lan.sh      | Wake-on-LAN script for GPU Node      |
| readme.md           | This configuration guide             |

---

## Notes

- GPU Node runs on-demand to save power (idle: ~100-150 W)
- Use Wake-on-LAN from Main Node or any network device
- Ensure network interface supports Wake-on-LAN (check BIOS settings)
- GPU passthrough configured for VM compute tasks
