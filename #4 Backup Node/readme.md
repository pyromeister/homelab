# Wake-On-Lan
WOL prüfen
Terminal PBS (enp2s0 entsprechend an deinen Netzwerknamen anpassen):
>ethtool enp2s0 | grep Wake-on

Ergebnis sollte etwas sein wie :
>Supports Wake-on: pumbg
Wake-on: g

wenn nicht, g sondern ggf. d dann aktivieren :
>ethtool -s enp2s0 wol g

in die '/etc/network/interfaces' via Nano unter dem entsprechenden iface den post-up eintrag hinzufügen Bsp:

>auto enp2s0
iface enp2s0 inet static
    address 192.168.178.5
    netmask 255.255.255.0
    gateway 192.168.178.1
    post-up /sbin/ethtool -s enp2s0 wol g

und dann den Netzwerk dienst neustarten
>systemctl restart networking
