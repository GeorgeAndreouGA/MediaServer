# MediaServer

Setup notes and configuration for a self-hosted home server: a hardened Raspberry Pi (or similar) running Docker services behind a DMZ/internal reverse-proxy split, with Cloudflare DNS, a VPN exit node, and a local DNS resolver.

This is a personal reference, not a turnkey installer — commands use `<placeholder>` values throughout (IPs, domains, passwords) that you fill in for your own network.

## Architecture

```
Public traffic:   Cloudflare → Gateway → [DMZ proxy :443] → [Internal server :443] → App
Admin/LAN traffic:            LAN or VPN client → [Internal server :443] → App
```

- **DMZ proxy** — the only thing facing the public internet, and only reachable through Cloudflare (its own IP allow-list enforces this). It forwards public routes to the internal server and hard-blocks admin routes outright.
- **Internal server** — runs the real reverse-proxy logic and talks to each service over `127.0.0.1`. Reachable from the DMZ (public routes only) and directly from LAN/VPN clients (everything, including admin).
- **Golden rule**: admin functionality for any site is reachable *only* through the internal server, from LAN or VPN — never through the DMZ. See [Reverse Proxy Architecture](<nginx and cloudflare configurations/6. reverse proxy architecture ( dmz + internal ).md>) for the full model.

Every containerized service binds its host port to `127.0.0.1` only — nginx and the host firewall (UFW) are what actually control access, never Docker's own port publishing.

## Getting started

Follow these in order on a fresh server:

1. **[Server Setup (Do First)](<Server set Up ( Do first )>)** — static IP, SFTP, SSH hardening, UFW, Docker, and a Tailscale VPN exit node.
2. **[Nginx &amp; Cloudflare Configuration](<nginx and cloudflare configurations>)** — domain/DNS setup, SSL certificates via [sslfree.io](https://sslfree.io), Cloudflare WAF rules, and the DMZ/internal reverse-proxy split.
3. **[Services](< Services>)** — the services themselves.

## Services

| Service | Method | Purpose |
| --- | --- | --- |
| [Emby](< Services/emby ( docker )>) | Docker | Media server |
| [Homer](< Services/homer ( docker )>) | Docker | Dashboard linking to every service |
| [n8n](< Services/n8n ( docker )>) | Docker | Workflow automation |
| [Pi-hole](< Services/pi-hole ( docker )>) | Docker | Ad-blocking DNS + local DNS resolver for internal domains |
| [Portainer](< Services/portainer ( docker )>) | Docker | Docker management UI — internal-only, admin tool |
| [Zabbix](< Services/zabbix ( bare metal )>) | Bare metal | Monitoring — runs on the host itself rather than in a container, so it doesn't share a failure domain with what it's monitoring |

## Security model, in short

- **Loopback-only containers**: every service's host port is `127.0.0.1:<port>`, never the LAN IP — see [Firewall (UFW)](<Server set Up ( Do first )/4. ufw ( firewall ).md>).
- **Two-tier reverse proxy**: public traffic is proxied DMZ → internal; admin traffic goes LAN/VPN → internal directly. Enforced per-route, in both nginx configs.
- **Cloudflare-only DMZ ingress**: the DMZ only accepts connections from Cloudflare's published IP ranges.
- **VPN exit node**: [Tailscale](<Server set Up ( Do first )/6. vpn ( tailscale ).md>) gives remote access to everything the LAN can reach, without port-forwarding anything beyond 80/443.
- **Local DNS**: Pi-hole resolves internal-only domains for LAN/VPN clients; public-site domains are deliberately **not** added there — see [DNS layers](<nginx and cloudflare configurations/5. setting a domain name with ssl cert.md>) for why.
- **Three-tier user model**: root runs every service; a regular user has shell access; an SFTP-only user is chrooted with no shell — see [SFTP](<Server set Up ( Do first )/2. sftp.md>).
