# SOC – Intrusion Detection Simulation
This lab is currently under development.
This project simulates a cyberattack within a virtualized network environment using GNS3, with the goal of detecting the intrusion using Suricata IDS. It is designed to demonstrate a typical workflow for a SOC analyst: monitoring, detecting, and analyzing malicious traffic in a segmented network.

## Purpose

- Demonstrate basic offensive and defensive security concepts.
- Build hands-on experience with IDS tools and network monitoring.
- Practice troubleshooting and system configuration in a lab environment.
- Document and present project work in a professional format.

## Tools & Technologies

- GNS3 – Network emulation platform
- Kali Linux – Attacker machine (Red Team)
- Ubuntu Server – Target system with Suricata IDS (Blue Team)
- VyOS – Virtual router for internal segmentation and NAT
- Suricata – Intrusion Detection System
- Wireshark – Packet analysis
- Netplan, nmtui, tcpdump, nmap, netcat

## Network Topology

```
[ INTERNET (NAT) ]
       |
     eth0
  [ VYOS Router ]
   /        \
eth1       eth2
 |           \
Kali        Ubuntu (Suricata)
```

An additional passive monitoring interface (`ens4`) was added to the server to allow Suricata to capture mirrored traffic between Kali and VyOS via a virtual hub.



## Network Configuration and Routing

The project demonstrates applied networking skills in configuring segmented IP networks and routing in VyOS. Key elements include:

- Assigning static IPs to interfaces on Kali and Ubuntu using `nmtui` and `netplan`
- Configuring VyOS interfaces:
  - eth0: DHCP for outbound Internet (NAT)
  - eth1: 10.0.X.X/24 (LAN to Kali)
  - eth2: 10.0.X.X/24 (LAN to Ubuntu)
- Enabling NAT masquerading on VyOS to route internal traffic:
```bash
configure
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '10.0.0.0/16'
set nat source rule 100 translation address 'masquerade'
commit
save
```
- Confirming connectivity and routing with ping, tcpdump, and internet access tests

## Project Phases

### Environment Setup

- Installed and configured Kali and Ubuntu via GNS3
- Established internal subnets using VyOS with NAT support
- Verified internet access and internal routing

### Suricata Installation & Configuration

- Installed Suricata and configured it to listen on correct interface
- Added a passive network interface for traffic sniffing
- Activated promiscuous mode and confirmed packet capture with tcpdump

### Rule Management & IDS Testing

- Downloaded rule sets using `suricata-update`
- Verified Suricata configuration (suricata.yaml) and rule path
- Customized detection rules for Nmap SYN scans and known threats (e.g. testmyids.com)
- Successfully triggered alerts using nmap and curl

## Screenshots

- images/Internet-Access-Kali.png
- images/Suricata-Active.png
- images/Suricata-Rules-Implemented.png
- images/Suricata-Response-Finally.png

## File Structure

```plaintext
SOC-Intrusion-detection/
├── README.md
├── images/
│   ├── Topology.png
│   ├── Suricata-Active.png
│   ├── Suricata-Response-Finally.png
│   └── ...
├── scripts/
│   ├── fix_suricata_nmap_rules.sh
│   └── update_suricata_interface.sh
├── configs/
│   ├── suricata.yaml (optional sanitized copy)
│   └── 50-cloud-init.yaml (optional)
└── logs/ (optional sample Suricata logs)
```
Note: Configuration and log files are uploaded with the .txt extension to ensure compatibility with GitHub's web interface. Internal IP addresses have been masked (e.g., 10.0.X.X) for privacy and security.

## Lessons Learned

- Importance of placing IDS in correct network position
- Managing IP addressing, gateway, NAT rules in VyOS
- Challenges with traffic visibility and how promiscuous mode helps
- Adjusting Suricata rules and HOME_NET for proper detection

## Resources

- https://suricata.io/docs/
- https://docs.vyos.io/en/sagitta/configuration/index.html
- https://docs.gns3.com

## Key Commands Used

### General System Updates
```bash
sudo apt update && sudo apt upgrade -y
```

### Suricata Installation & Checks
```bash
sudo apt install suricata -y
sudo systemctl restart suricata
sudo systemctl status suricata
```

### Network Configuration (Kali & Ubuntu)
```bash
sudo nmtui
sudo nano /etc/netplan/50-cloud-init.yaml
sudo netplan apply
```

### IDS Log Monitoring
```bash
sudo tail -f /var/log/suricata/fast.log
sudo tail -f /var/log/suricata/eve.json | jq '{src: .src_ip, dest: .dest_ip, proto: .proto}'
```

### Suricata Rule Management
```bash
sudo apt install suricata-update -y
sudo suricata-update
grep -i "ET SCAN NMAP" /var/lib/suricata/rules/suricata.rules | grep '^alert'
```

### Network Scanning from Kali
```bash
nmap -sS 10.0.2.10
nmap -sS -p 80 10.0.2.10
curl http://testmyids.com
```

### Bash Script Utilities
```bash
chmod +x fix_suricata_nmap_rules.sh
./fix_suricata_nmap_rules.sh
chmod +x update_suricata_interface.sh
./update_suricata_interface.sh
```

### Diagnostic Tools
```bash
tcpdump -i ens4 tcp
ip a
ip link | grep PROMISC
```




