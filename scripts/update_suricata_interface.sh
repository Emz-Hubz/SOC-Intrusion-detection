#!/bin/bash

# Detta skript identifierar ett interface i PROMISC-läge
# och uppdaterar Suricatas konfigurationsfil (suricata.yaml)
# så att den lyssnar på det interfacet.

# Identifiera första interface i PROMISC-läge
PROMISC_IFACE=$(ip link | grep PROMISC | awk -F': ' '{print $2}' | head -n1)

# Avbryt om inget interface hittas
if [ -z "$PROMISC_IFACE" ]; then
  echo "Inget interface i PROMISC-läge hittades. Avslutar."
  exit 1
fi

echo "Interface identifierat: $PROMISC_IFACE"

# Skapa säkerhetskopia av suricata.yaml
sudo cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak

# Uppdatera suricata.yaml med nytt interface under af-packet-sektionen
sudo sed -i "/af-packet:/,/^- interface:/ s/^- interface:.*/  - interface: $PROMISC_IFACE/" /etc/suricata/suricata.yaml

echo "suricata.yaml har uppdaterats med interface: $PROMISC_IFACE"
