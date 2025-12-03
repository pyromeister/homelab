# Homelab Hardware Documentation

## Table of Contents
- [Overview](#overview)
- [Hardware Nodes](#hardware-nodes)
  - [Mainserver](#mainserver--running-247)
  - [NAS Node](#nas-node--running-247)
  - [GPU Node](#gpu-node--running-as-needed)
  - [Backup Node](#backup-node--running-as-needed)
- [Cost Summary](#cost-summary)
- [Power Consumption](#power-consumption)
  - [Idle Power Usage](#idle-power-usage)
  - [Daily Power Consumption](#daily-power-consumption)
  - [Estimated Monthly Costs](#estimated-monthly-costs)

---

## Overview

This homelab consists of 4 nodes serving different purposes:
- **2 nodes running 24/7**: Mainserver (Proxmox) and NAS Node (TrueNAS)
- **2 nodes on-demand**: GPU Node and Backup Node (Wake-on-LAN)

**Total Investment**: 1,288.31 €
**Total Storage Capacity**: 32 TB (2× 16 TB HDDs)
**24/7 Idle Power Consumption**: ~22 W

---

## Hardware Nodes

### **Mainserver** – *running 24/7*

| Component       | Details                                                                     |
|-----------------|-----------------------------------------------------------------------------|
| **Model**       | Lenovo ThinkCentre M920q Tiny *(eBay with 8GB RAM – 259.00 € – 2025-08-13)* |
| **CPU**         | Intel i7-8700T                                                              |
| **RAM**         | 32 GB (2×16 GB) *(Amazon – 74.52 € – 2025-08-13)*                           |
| **Storage**     | 250 GB SSD                                                                  |
| **Idle Power**  | ~12 W                                                                       |
| **OS**          | Proxmox VE                                                                  |
| **Usage**       | Containers & VMs for Jellyfin, Immich, Nginx, etc.                          |

---

### **NAS Node** – *running 24/7*

| Component         | Details                                                               |
|-------------------|-----------------------------------------------------------------------|
| **Model**         | Lenovo ThinkCentre M625q Tiny *(eBay – 69.00 € – 2025-03-19)*         |
| **CPU**           | AMD E2-9000E                                                          |
| **RAM**           | 8 GB                                                                  |
| **Storage**       | 128 GB SSD                                                            |
| **External Case** | TerraMaster D2-320 USB 3.2 *(Amazon – 118.99 € – 2025-08-13)*         |
| **HDDs**          | 2× 16 TB *(Amazon – 2× 166.00 € = 332.00 € – 2024-03-20)*             |
| **Idle Power**    | ~10 W                                                                 |
| **OS**            | TrueNAS Scale                                                         |
| **Usage**         | NAS, Samba shares, network storage                                    |

---

### **GPU Node** – *running as needed* (Wake-on-LAN)

| Component       | Details                                                                 |
|-----------------|-------------------------------------------------------------------------|
| **Model**       | Desktop PC *(Agando – 364.80 € – 2023-12-01)*                           |
| **CPU**         | AMD Ryzen 5 5600G (6× 4.4 GHz)                                          |
| **RAM**         | 32 GB DDR4 PC-3000 (2×16 GB)                                            |
| **GPU**         | Nvidia P2000                                                            |
| **Storage**     | NVMe M.2 SSD 500 GB Kingston NV2                                        |
| **Idle Power**  | ~100–150 W                                                              |
| **OS**          | Proxmox VE                                                              |
| **Usage**       | VM with GPU Passthrough for compute tasks                               |

---

### **Backup Node** – *running as needed* (Wake-on-LAN)

| Component       | Details                                                                 |
|-----------------|-------------------------------------------------------------------------|
| **Model**       | Lenovo ThinkCentre M625q Tiny *(eBay – 69.00 € – 2025-03-19)*           |
| **CPU**         | AMD E2-9000E                                                            |
| **RAM**         | 8 GB                                                                    |
| **Storage**     | 128 GB SSD                                                              |
| **External**    | Planned: 8 TB external HDD (~170.00 €)                                  |
| **OS**          | TBD                                                                     |
| **Usage**       | Backup storage and disaster recovery                                    |

---

## Cost Summary

### Hardware Costs

| Component                      | Description                           | Price (€)  |
|--------------------------------|---------------------------------------|------------|
| Mainserver                     | Lenovo ThinkCentre M920q Tiny         | 259.00     |
| Mainserver RAM                 | Crucial DDR4 (2×16GB) CT2K16G4SFRA32A | 74.52      |
| NAS Node                       | Lenovo ThinkCentre M625q Tiny         | 69.00      |
| DAS Enclosure                  | TerraMaster D2-320                    | 118.99     |
| NAS Storage                    | 2× 16 TB Seagate Exos X16 ST16000NM000J | 332.00  |
| GPU Node                       | Custom Desktop PC                     | 364.80     |
| Backup Node                    | Lenovo ThinkCentre M625q Tiny         | 69.00      |
| USB Adapter                    | Amazon Basics USB-C to USB-A 3.1 Gen2 | 8.99       |
| **Total Investment**           |                                       | **1,287.30** |

### Planned Additions

| Component                      | Description                           | Estimated Price (€) |
|--------------------------------|---------------------------------------|---------------------|
| Backup Storage                 | 8 TB External HDD                     | ~170.00             |

---

## Power Consumption

### Idle Power Usage

Power usage is measured with smart power plugs for accurate monitoring.

| Node                  | Status      | Idle Power | Hours/Day | Daily kWh |
|-----------------------|-------------|------------|-----------|-----------|
| Mainserver            | 24/7        | ~12 W      | 24        | 0.288     |
| NAS Node              | 24/7        | ~10 W      | 24        | 0.240     |
| GPU Node              | On-demand   | ~100-150 W | Variable  | Variable  |
| Backup Node           | On-demand   | ~10 W      | Variable  | Variable  |
| **24/7 Total**        | —           | **~22 W**  | —         | **0.528** |

### Daily Power Consumption

| Node                  | Average Daily kWh | Notes                                    |
|-----------------------|-------------------|------------------------------------------|
| Mainserver            | 0.288             | Running continuously                     |
| NAS Node              | 0.240             | Running continuously                     |
| GPU Node              | Variable          | Only when needed via Wake-on-LAN         |
| Backup Node           | Variable          | Only when needed via Wake-on-LAN         |
| **Total (24/7 nodes)**| **0.528**         | Base consumption                         |

### Estimated Monthly Costs

Assuming an electricity rate of **0.30 €/kWh** (adjust based on your location):

| Period    | Consumption (kWh) | Cost (€) |
|-----------|-------------------|----------|
| Daily     | 0.528             | 0.16     |
| Monthly   | 15.84             | 4.75     |
| Yearly    | 192.72            | 57.82    |

> **Note**: These calculations are for 24/7 nodes only. On-demand nodes (GPU and Backup) will increase costs when active.

---

## Notes

- Power measurements are taken using smart power plugs
- All dates standardized to ISO format (YYYY-MM-DD)
- On-demand nodes use Wake-on-LAN to minimize power consumption
- Cost estimates assume 0.30 €/kWh electricity rate
- Future additions (8 TB backup drive) not included in total cost
