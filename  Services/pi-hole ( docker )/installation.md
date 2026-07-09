# Pi-hole — Installation

Pi-hole doubles as this network's ad-blocking DNS **and** its local DNS server — the thing that resolves internal-only domains for LAN/VPN clients (see [DNS layers: Cloudflare vs. local DNS](<../../nginx and cloudflare configurations/5. setting a domain name with ssl cert.md>)).

## 1. Create the service directory

```bash
mkdir -p /root/Docker/pi-hole
```

Place `pi-hole.yaml` there, and create `.env` from `.env.example` (see this folder) with your own timezone and admin password.

## 2. Start the container

```bash
docker compose -f /root/Docker/pi-hole/pi-hole.yaml up -d
```

## 3. Reverse proxy

Like n8n, Pi-hole's web UI can't be served under `domain.com:port/something` — it needs `domain.com:port/` or `subdomain.domain.com:port/` at the root. A CNAME subdomain in Cloudflare (proxy toggle **off** — this is internal-only) works well here; the matching nginx site config should follow the same internal-only, LAN/VPN-allow-listed pattern as the other internal services (see [Reverse Proxy Architecture](<../../nginx and cloudflare configurations/6. reverse proxy architecture ( dmz + internal ).md>)). Access it over HTTPS only — issue it a certificate first.

## 4. Configure Pi-hole as the local DNS server

After logging in to the Pi-hole admin UI:

1. **Settings → DNS** — turn on **Expert Mode**.
2. Set **Permit all origins**. This is safe here specifically because port 53 is never exposed to the internet (see `pi-hole.yaml` — no public bind address, LAN/VPN only) — the only reason it's needed at all is that Docker's network layer would otherwise get treated as an untrusted origin.
3. Under **Advanced DNS settings**, turn **off** both:
   - "Never forward reverse lookups for private IP ranges"
   - "Never forward non-FQDN queries"

   Leave **Use DNSSEC** off unless your nameserver supports it — since this setup uses Cloudflare as the nameserver, DNSSEC can be enabled on both the Cloudflare side and here together if you want it.
4. **Settings → Local DNS records** — point each internal domain/subdomain at the LAN IP of whichever server actually hosts it (not just this server's services — anything on your network).
5. On your router, change the **primary DNS** handed out by DHCP to this server's IP. A secondary DNS is optional — see the [static IP guide's DNS table](<../../Server set Up ( Do first )/1. set_static_ip.md>) for why leaving it blank is often the safer choice.
6. Power-cycle the router. Every device that reconnects afterward will pick up Pi-hole as its DNS server automatically, getting both ad-blocking and internal name resolution.

## Common pitfalls

- **A client device won't resolve internal names:** check that it isn't overriding the DHCP-assigned DNS server itself — most commonly a phone's "Private DNS" setting (Android) set to something other than automatic/off. This silently bypasses Pi-hole entirely.
- **Stale results after a first-time setup:** clear the client's DNS cache/cookies before troubleshooting further.
- **Pi-hole itself is down:** any client can always fall back to reaching services by the server's private IP directly (see the relevant nginx config) until Pi-hole is back up.
