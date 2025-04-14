# Troubleshooting Guide – SOC Intrusion Detection Project

This document contains known issues, symptoms, and solutions encountered during the development and testing of the SOC simulation project in GNS3.

---

## 1. Suricata does not detect Nmap SYN scans

**Symptoms:**
- `nmap -sS` scan produces no alerts
- Suricata is active but `fast.log` remains empty

**Possible Causes:**
- All ports on the target are closed
- `suricata.rules` lacks active ET SCAN NMAP rules
- Suricata is not listening on the correct interface
- Interface not in PROMISC mode

**Solutions:**
- Open a port manually: `nc -lvnp 80` on server
- Use helper script: `fix_suricata_nmap_rules.sh`
- Check interface config in `suricata.yaml` → use `ens4`
- Run `ip link set ens4 promisc on`

---

## 2. Suricata fails to start or crashes on restart

**Symptoms:**
- `sudo systemctl restart suricata` fails
- `journalctl` shows error on interface like `eth1: No such device`

**Cause:**
- Incorrect interface name in `suricata.yaml`

**Solution:**
- Use script: `update_suricata_interface.sh` to automatically set correct PROMISC interface

---

## 3. No traffic is visible in Suricata (even with Nmap)

**Symptoms:**
- `tail -f fast.log` or `eve.json` shows no activity
- `nmap` clearly sends traffic (confirmed by tcpdump)

**Possible Causes:**
- Sniffing interface (e.g. ens4) not connected to correct segment
- GNS3 switch not mirroring traffic
- Suricata interface lacks PROMISC mode

**Solutions:**
- Replace switch with hub in GNS3 topology
- Ensure Suricata listens on a sniff-only interface
- Use `tcpdump -i ens4 tcp` to confirm traffic visibility

---

## 4. `suricata.rules` has no effect after modification

**Cause:**
- Rules are still commented or improperly indented

**Solution:**
- Use script: `fix_suricata_nmap_rules.sh`
- Manually verify with:
  ```bash
  grep -i "ET SCAN NMAP" /var/lib/suricata/rules/suricata.rules
  ```

---

## 5. Suricata interface not logging EVE or FAST

**Symptoms:**
- No `/var/log/suricata/fast.log` or `eve.json` updates

**Solution:**
- Check file permissions on log directory
- Ensure Suricata is started with correct config:
  ```bash
  sudo suricata -c /etc/suricata/suricata.yaml -i ens4
  ```