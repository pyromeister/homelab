#!/bin/bash
# wake-server.sh
# Skript zum Starten des GPU Node via Wake-on-LAN

# MAC-Adresse des GPU Node (Anpassen mit der echten MAC-Adresse)
MAC="XX:XX:XX:XX:XX:XX"

# Optional: Broadcast-Adresse des Netzwerks
BROADCAST="192.168.X.255"

# Prüfen, ob wakeonlan installiert ist
if ! command -v wakeonlan &> /dev/null
then
    echo "wakeonlan ist nicht installiert. Installiere es mit: sudo apt install wakeonlan"
    exit 1
fi

# Wake-on-LAN Magic Packet senden
echo "Sende WoL-Paket an $MAC über Broadcast $BROADCAST..."
wakeonlan -i $BROADCAST $MAC

echo "Paket gesendet. Warte ein paar Sekunden, bis der GPU Node startet."
