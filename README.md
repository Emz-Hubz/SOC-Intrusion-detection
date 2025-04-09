# SOC-Intrusion Detection Simulation

This project simulates a cyberattack inside a virtual network built using GNS3. The goal is to demonstrate how a SOC analyst detects and responds to threats using open-source tools.

---

## Purpose

- Practise offensive and defensive cybersecurity techniques
- Learn how to configure and use IDS (Intrusion Detection Systems)
- Document findings in a professional and structured way

## Tools & Technologies

- GNS3
- Kali Linux (attacker)
- VyOS (router)
- Ubuntu Server (target)
- Suricata (IDS)
- Wireshark

---

## Network Topology

```
Kali-attacker  <-->  VyOS Router  <-->  Ubuntu Server (Suricata)
                           |
                         (NAT)
```

---

## Internet Access (Kali)

During setup, Kali was temporarily connected to a NAT interface to update packages.

Steps:

- Connected Kali to NAT (`int2`) in GNS3
- Used `nmtui` to enable DHCP and received IP from `192.168.122.0/24`
- Verified with:
  - `ip a`
  - `ping 8.8.8.8`
  - `ping google.com`

---

## Suricata IDS Setup (Ubuntu Server)

### Step 1: Initial Setup

- Installed Suricata:

  ```bash
  sudo apt install suricata -y
  ```

- Edited config:

  ```bash
  sudo nano /etc/suricata/suricata.yaml
  ```

- Set interface to sniff traffic (initially):

  ```yaml
  af-packet:
    - interface: ens3
  ```

- Restarted Suricata:

  ```bash
  sudo systemctl restart suricata
  ```

### Step 2: Rule Update & Test

- Installed updater:

  ```bash
  sudo apt install suricata-update -y
  sudo suricata-update
  ```

- Ensured default ruleset:

  ```yaml
  rule-files:
    - suricata.rules
  ```

- Verified detection by accessing:

  ```bash
  curl http://testmyids.com
  ```

- Checked logs:

  ```bash
  sudo tail -f /var/log/suricata/fast.log
  ```

---

## Installation & Configuration

### VyOS Router

- NAT masquerading configured on `eth0` (external interface)
- Internal routing between segments `10.0.1.0/24` and `10.0.2.0/24`

### Ubuntu Server (24.04)

- Suricata installed via APT
- Listening on `ens4` (connected to hub)
- Configured with `HOME_NET: [10.0.0.0/16]`

### Kali Linux

- Used to simulate attacks (`nmap -sS`, `curl http://testmyids.com`)

---

## Attack Simulation Results

### IDS test with testmyids.com

- Command: `curl http://testmyids.com`
- Triggered `GPL ATTACK_RESPONSE` rule in `/var/log/suricata/fast.log`

### SYN-scan from Kali

- Initially no alerts (all ports closed)
- After running `nc -lvnp 80` on server + `nmap -sS` from Kali:
- Alert triggered: `SURICATA STREAM SHUTDOWN RST invalid ack`

---

## Scripts for Automation

Located in `scripts/setup/`:

- `fix_suricata_nmap_rules.sh`
  - Uncomments and formats Nmap-related rules in `suricata.rules`

- `update_suricata_interface.sh`
  - Detects PROMISC-mode interfaces and updates `suricata.yaml` accordingly

---

## Troubleshooting Tips

- Suricata must run on an interface in **PROMISC mode** to sniff via hub
- Verify `HOME_NET` is correctly set (e.g., `10.0.0.0/16`)
- SYN-scans require **open ports** to trigger stream-related alerts
- Rules in `suricata.rules` must be uncommented and correctly formatted


