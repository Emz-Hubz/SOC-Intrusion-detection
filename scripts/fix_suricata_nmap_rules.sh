#!/bin/bash

# File: fix_suricata_nmap_rules.sh
# Purpose: Ensure Nmap-related rules in suricata.rules are uncommented and correctly formatted

# Path to rule file
RULEFILE="/var/lib/suricata/rules/suricata.rules"

# Create backup
BACKUP="/var/lib/suricata/rules/suricata.rules.bak"
echo "[+] Creating backup of original rule file..."
sudo cp "$RULEFILE" "$BACKUP"

# Uncomment lines related to Nmap scan detection (ET SCAN NMAP)
echo "[+] Uncommenting Nmap-related rule lines..."
sudo sed -i -E 's/^#\s*(alert tcp .*ET SCAN NMAP)/\1/' "$RULEFILE"

# Remove incorrect indentation on uncommented alert rules (optional hygiene)
echo "[+] Removing excess leading whitespace..."
sudo sed -i -E 's/^\s+(alert tcp)/\1/' "$RULEFILE"

# Done
echo "[+] Done. Use the following command to verify:"
echo "    grep -i 'ET SCAN NMAP' $RULEFILE"
