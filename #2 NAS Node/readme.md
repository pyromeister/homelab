Truenas Scale heruntergeladen
image via tool auf Stick
Truenas installiert
nach Truenas anleitung angemeldet, Benutzer angelegt
1 Datastorage angelegt mit einer Festplatte (DAS via USB-C zu USB-A)
Dataset angelegt
darunter SMB Dataset angelegt (Datentransfer im Netzwerk)
Berechtigungen via Share ACL angelegt

Proxmox selbst wollte via GUI nicht richtig den SMB einfügen, via Terminal geprüft:
> pvesm cifsscan 192.168.178.21 --username "proxmox" --password
Enter Password: **********
smb 

als nächstes das SMB eingebunden via:
> pvesm add cifs SMB1 --server 192.168.178.21 --share "smb" --username "proxmox" --password

> "SMB1" = angezeigter Name
rest dürfte selbsterklärend sein

Proxmox Storage nun wie folgt:
Local ()
PBS (Proxmox Backup Server)
data2 (2TB M2 SSD)
SMB1 (SMB Share von NAS)