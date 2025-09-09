RAM eingebaut (32GB)
PVE installiert, update und upgrade
PBS Storage verbunden
SMB von OMV verbunden 

umbenennen der Node in
/etc/hosts
/etc/hostname

Habe noch eine alte 500GB SSD gefunden, eingebaut und als Directory eingebunden
Direkt auf der Node via Disks, "Initialize Disk with GPT" und danach unter Disks->Directory "Create:Directory" mit xfs eingebunden.



via terminal von meinem desktop aus die iso`s des bestehenden Server downloaden:
scp root@192.168.178.10:/var/lib/vz/template/iso/* ~/Downloads/
danach auf neuem Main Node, via GUI einfach uploaden

Backup des Alt Systems (PBS), danach Restore auf der Mainnode
zuerst ein Test um zu schauen ob IP&MAC noch passen (damit keine Netzwerkanpassungen notwendig sind) -> erfolgreich

Ich nutze gerne IP Tags, hierfür gibt es ein fertiges Script:
https://community-scripts.github.io/ProxmoxVE/scripts?id=add-iptag&category=Proxmox+%26+Virtualization

# Conbee 3 für MQTT
der Conbee Stick ist via USB angeschlossen, direkt im Datacenter als USB Gerät inkludiert und der mqtt Container nutzt diesen direkt (Thema Smarthome)


# Favorisierte LXC Container:
- cloudflared
- mqtt
- zigbee2mqtt
- vaultwarden
- homarr
- nginxproxymanager
- pihole
- immich

# Mailing Proxmox
- Datacenter -> Notifications
- Add SMTP, deactivate mail-to-root, change default-matcher "targets-to-notify" to new configured smtp

# Grafana, Prometheus, Prometheus-PVE-Exporter
- install all via Helper Scripts as LXC
- changed "/etc/prometheus/prometheus.yml" (see yml file here)
- added new user (prometheus) as PVE user
-> under permission gave the prometheus for / the PVEAuditor rights
-> changed in pve-exporter the "/opt/prometheus-pve-exporter/pve.yml"

# Wake-On-Lan Konfigurieren
zuerst mal installieren:
>apt update
apt install wakeonlan -y

# ssh key für PBS vorbereiten, damit shutdown auch funktioniert
PVE Terminal:
>ssh-keygen -t ed25519

Kopieren auf den PBS Server:
>ssh-copy-id root@192.168.178.5

Test:
>ssh root@192.168.178.5 "echo ok"

Wenn ok kommt, funktioniert es.

# CronJob für Wake-On-Lan und Shutdown der Backup Node
>crontab -e

Beim ersten Mal fragt er dich evtl. nach einem Editor – nimm nano, wenn du unsicher bist.
Am Ende der Datei dann die Cronjobs hinzufügen, für mich ist es Sonntags 00:30Uhr wake on lan und Sonntags 06:00Uhr shutdown:
>30 0 * * 0 /usr/bin/wakeonlan 6c:4b:90:c7:7b:c5
0 6 * * 0 ssh root@192.168.178.5 "shutdown -h now"
