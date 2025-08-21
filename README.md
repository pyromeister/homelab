| Deutsch | Englisch |
|---------|----------|
|Es handelt sich hierbei um eine Dokumentation für meine Erfahrungen die ich mache mit Homeservern | This is a documentation of my experiences with home servers. |

---

Notizen:
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

TrueNAS nutzt automatisch ZFS, gut aber frisst mir zu viel RAM
daher download und installation von OpenMediaVault
erstanmeldung nach anleitung von OMV
updates fahren und PW ändern
Neue Benutzer anlegen (für mich und proxmox für smb)
Dateisystem anlegen, XFS hat via DAS irgendwie nicht funktioniert... 
EXT4 wird genutzt
Freigabe SMB -> angelegt, DOS Attribute speichern aktiviert
SMB selbst -> Minimal auf SMB1 stellen

einbinden in Proxmox GUI oder via pvesm add cifs funktioniert nicht.
smbcredentials file angelegt, rechte auf 600 gestellt und fstab modifiziert, mount -a funktioniert

Reicht für mich, schade das es nicht funktioniert... wird auf später verschoben