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

