#!/bin/bash
# wake-server.sh
# Skript zum Starten eines Servers via Wake-on-LAN

# MAC-Adresse des Servers (Anpassen vom Zielserver/ZielPC)
MAC="d8:43:ae:xx:xx:xx"

# Optional: Broadcast-Adresse des Netzwerks (da meine IP Range 192.168.178.0 ist)
BROADCAST="192.168.178.255"

# Prüfen, ob wakeonlan installiert ist
if ! command -v wakeonlan &> /dev/null
then
    echo "wakeonlan ist nicht installiert. Installiere es mit: sudo apt install wakeonlan"
    exit 1
fi

# Wake-on-LAN Magic Packet senden
echo "Sende WoL-Paket an $MAC über Broadcast $BROADCAST..."
wakeonlan -i $BROADCAST $MAC

echo "Paket gesendet. Warte ein paar Sekunden, bis der Server startet."
