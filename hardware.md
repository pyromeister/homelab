# Power Usage Overview
Power usage will be measured with Smart Power Plugs.  
An average consumption will be added here once available.

---

# [**Mainserver**](./#1%20Main%20Node/readme.md) – *running 24/7*
| Component       | Details                                                                     |
|-----------------|-----------------------------------------------------------------------------|
| **Model**       | Lenovo ThinkCentre M920q Tiny *(Ebay with 8GB RAM – 259,00 € – 13.08.2025)* |
| **CPU**         | Intel i7-8700T                                                              |
| **RAM**         | 32 GB (2×16 GB) *(Amazon – 74,52 € – 13.08.2025)*                           |
| **Storage**     | 250 GB SSD                                                                  |
| **Idle Power**  | ~12 W                                                                       |
| **OS**          | Proxmox VE                                                                  |
| **Usage**       | Container, VMs for Jellyfin, Immich, Nginx, etc.                            |

---

# **NAS Node** – *running 24/7*
| Component         | Details                                                               |
|-------------------|-----------------------------------------------------------------------|
| **Model**         | Lenovo ThinkCentre M625q Tiny *(eBay – 69,00 € – 19.03.2025)*         |
| **CPU**           | AMD E2-9000E                                                          |
| **RAM**           | 8 GB                                                                  |
| **Storage**       | 128 GB SSD                                                            |
| **External Case** | TerraMaster D2-320 USB 3.2 *(Amazon – 118,99 € – 13.08.2025)*         |
| **HDDs**          | 2× 14 TB *(Amazon - 2x 166 € = 332€ - 20.03.2024)*                    |
| **Idle Power**    | ~10 W                                                                 |
| **OS**            | TrueNAS Scale                                                         |
| **Usage**         | NAS, Samba, ...                                                       |

---

# **GPU Node** – *running as needed* (Wake-on-LAN)
| Component       | Details                                                                 |
|-----------------|-------------------------------------------------------------------------|
| **Model**       | Desktop PC *(Agando - 364,80 € - 01.12.2023)*                           |
| **CPU**         | AMD Ryzen 5 5600G (6× 4.4 GHz)                                          |
| **RAM**         | 32 GB DDR4 PC-3000 (2×16 GB)                                            |
| **GPU**         | Nvidia P2000                                                            |
| **Storage**     | NVMe M.2 SSD 500 GB Kingston NV2                                        |
| **Idle Power**  | ~100–150 W                                                              |
| **OS**          | Proxmox VE                                                              |
| **Usage**       | VM with GPU Passthrough                                                 |

---

# **Backup Node** – *running as needed* (Wake-on-LAN)
| Component       | Details                                                                 |
|-----------------|-------------------------------------------------------------------------|
| **Model**       | Lenovo ThinkCentre M625q Tiny *(eBay – 69,00 € – 19.03.2025)*           |
| **CPU**         | AMD E2-9000E                                                            |
| **RAM**         | 8 GB                                                                    |
| **Storage**     | 128 GB SSD                                                              |
| **External**    | Planned: 8 TB external HDD (~170 €)                                     |
| **OS**          | ...                                                                     |
| **Usage**       | Backup, ....                                                            |

---


# **Price Summary**
| Node                  | Price             |
|-----------------------|-------------------|
| Mainserver            | 259,00 €          |
| RAM for Mainserver    | 74,52 €           |
| NAS Node              | 69,00 €           |
| Terramaster Case      | 118,99 €          |
| 2x 14 TB HDDs         | 332,00 €          |
| GPU Node              | 364,80 €          |
| Backup Node           | 69,00 €           |
|                       |                   |
| Together              | 1.288,31          |

---

# **Average Powerusage a day**
| Node                  | kw/h              |
|-----------------------|-------------------|
|||
|||
|||

---