# Network Schema and Configuration

Hardware: UniFi (Ubiquiti) — UCG-Ultra gateway, USW-Lite-8-PoE switches throughout, U6+ access points.

![Home network diagram](home_network.png)

## Segments (VLANs)

| VLAN    | Subnet                            | Gateway                         | Purpose                  | Devices                                                                                                  |
| ------- | --------------------------------- | ------------------------------- | ------------------------ | -------------------------------------------------------------------------------------------------------- |
| 1       | 192.168.1.0/24                    | 192.168.1.254                   | Management (native)      | Switches, APs, gateway — management interfaces only. No client device is ever assigned to this VLAN.    |
| 10      | 192.168.10.0/24                   | 192.168.10.254                  | Room 1 — clients        | PC-1, PC-2, VoIP PoE (access layer); SRV-A, SRV-B (server room)                                          |
| 20      | 192.168.20.0/24                   | 192.168.20.1                    | Room 2 — clients        | PC-1, PC-2, VoIP PoE (access layer); SRV-C, SRV-D (server room)                                          |
| 30      | 192.168.30.0/24                   | 192.168.30.254                  | Security                 | DVR, IP cameras — no internet access                                                                    |
| 40      | 192.168.40.0/24                   | 192.168.40.254                  | DMZ                      | Reverse proxy (Nginx/Caddy) — the only thing exposed to the internet; gateway port-forwards 80/443 here |
| 50 / 60 | 192.168.50.0/24 / 192.168.60.0/24 | 192.168.50.254 / 192.168.60.254 | Wireless                 | U6+ AP-1, U6+ AP-2 — SSIDs mapped one-to-one to these VLANs                                             |
| 70      | 192.168.70.0/24                   | 192.168.70.254                  | Shared internal services | DNS server (.10), Shared SRV 2 (.12), Shared SRV 3 (.13) — internal only, not internet-facing           |

## Firewall and inter-VLAN policy

The **Cloud Gateway (UCG-Ultra) is the firewall** for this network — every VLAN routes through it, and it's the only device with a path to the WAN.

**Default UniFi behavior:** out of the box, UniFi allows every VLAN to reach every other VLAN — inter-VLAN routing is implicitly permitted with no firewall rules required. Segmenting devices into VLANs by itself only gives topological separation, not access control.

**Applied policy:** block all VLAN-to-VLAN traffic by default, then add narrow allow rules only for the flows the design actually needs , **including the vpn's virual vlan to the destination vlan you want the vpn to have access to**.

## Port configuration policy

- **Switch ↔ switch (uplinks): 802.1Q trunk, STP port type = uplink.**
  - Tag every VLAN that needs to cross the link (10, 20, 30, 40, 50, 60, 70 as applicable).
  - Native VLAN = VLAN 1/default, used **only** for switch management traffic — no client access port anywhere is assigned to it.
  - These are the only ports that participate in STP as **non-edge (uplink)** ports — a switch is a bridge, so a loop is structurally possible here, and this is exactly what the root-priority tiers above are protecting.
- **Switch ↔ AP: 802.1Q trunk, STP port type = edge.**
  - Tag every VLAN an SSID needs (50 and 60 in this design) — each SSID is bound to one tagged VLAN.
  - Native VLAN = VLAN 1/default, for the AP's own management traffic.
  - Even though this is a trunk, the AP is an end device, not a bridge — so the port is still an **edge port**, transitioning straight to forwarding instead of waiting through STP's listening/learning delay.
- **Switch ↔ end device (access ports): untagged access port, STP port type = edge.**
  - PVID = the one VLAN that device belongs to (e.g. VLAN 10 for a Room 1 PC).
  - No other VLANs tagged or allowed on the port — a compromised or misconfigured device can't reach any other VLAN from there.
  - Exception to watch for: if a VoIP phone ever needs a separate voice VLAN for QoS while the PC behind it stays on the data VLAN, that specific port needs one tagged VLAN (voice) on top of the untagged data VLAN — a deliberate, narrow exception, not a general "allow tagged" rule.

**Rule of thumb:** switch-to-switch uplinks are the only non-edge ports in the network — everything else (clients and APs alike) is an edge port, since neither is itself a bridge and can't introduce a loop.

## Spanning tree (STP/RSTP) root priority

UniFi switches run RSTP by default even without a deliberate physical loop, as protection against an accidental one (a stray cable between two access ports, a future redundant uplink, etc.). Left on defaults, every switch has the same bridge priority (32768) and the root is decided only by lowest MAC address — arbitrary, and not necessarily the switch you'd want re-converging traffic through if a link fails.

**Rule:** bridge priority gets lower (more preferred as root) the closer a switch sits to the gateway, and higher (less preferred) the further down the topology it sits.

| Tier               | Switches                                        | Priority |
| ------------------ | ----------------------------------------------- | -------- |
| Core (root bridge) | Master Switch                                   | 4096     |
| Distribution       | Server Room SW, SW-DMZ/Shared, SW-R1-A, SW-R2-A | 8192     |
| Access / leaf      | SW-10, SW-20, SW-30, SW-50                      | 12288    |

This guarantees the Master Switch is always the root bridge as long as it's up, and that any recalculation after a link or switch failure still prefers paths back toward the core rather than electing a leaf switch as root.

## Hardening notes

- **Unused ports.** Factory-default switch ports fall back to access mode on VLAN 1. Any port left unconfigured is, in practice, a device on VLAN 1 — the one thing the design assumes doesn't exist. Unused ports should be **administratively shut down, not left at defaults**.
- **Further UniFi hardening options.** The controller exposes a lot more than what's captured in this document — **honeypot/deception features**, IDS/IPS, DPI, **geo-IP blocking**, ad blocking at the gateway, rogue AP/DHCP server detection, and per-client fingerprinting/isolation, among others. Worth periodically reviewing what's available in the Settings > Security and Settings > Networks screens as the controller adds features, rather than treating this document as the final word on hardening.
