# n8n — Installation

> n8n's own reverse-proxy requirements are picky enough that they get a dedicated nginx config — see [`nginx configs/internal/n8n_nginx.conf`](<../../nginx and cloudflare configurations/nginx configs/internal/n8n_nginx.conf>) and copy it as-is rather than improvising.

## 1. Get a subdomain

n8n needs its own subdomain (a bare `domain.com/n8n` path doesn't work reliably). In Cloudflare, add a `CNAME` record for your subdomain (e.g. `n8n`) pointing at your domain — see [Domain &amp; SSL setup](<../../nginx and cloudflare configurations/5. setting a domain name with ssl cert.md>) for the full DNS walkthrough. Every other service in this repo can take or leave a subdomain; n8n specifically needs one.

## 2. Create the service directory

```bash
mkdir -p /root/Docker/n8n
```

Place `n8n.yaml` there, and create `.env` from `.env.example` (see this folder) with your own subdomain, timezone, etc.

## 3. Start the container

```bash
docker compose -f /root/Docker/n8n/n8n.yaml up -d
```

## 4. Fix data ownership

```bash
ls -la /root/Docker/n8n/n8n-data
sudo chown -R <user>:<user> /root/Docker/n8n/n8n-data
```

**This must not be root.** n8n's own process refuses to run comfortably otherwise.

## 5. Reverse proxy

Use `nginx configs/internal/n8n_nginx.conf` as-is for the site config, then reload nginx.

## Reaching other internal services from n8n workflows

If a workflow needs to poll another internal service on this server (Emby, a monitoring endpoint, etc.) by its domain name, there's an extra wrinkle: **containers are isolated network namespaces.** Even though n8n runs on the same physical server, from inside the container it's effectively a separate machine trying to reach `domain.com` — and `domain.com` isn't publicly resolvable to begin with (it's internal-only, see [DNS layers](<../../nginx and cloudflare configurations/5. setting a domain name with ssl cert.md>)).

The fix follows the exact same pattern used for every other service reaching an internal domain — nginx + UFW allow-listing — except the "client" here is the n8n container, whose IP changes every time it restarts. Allow-list its **subnet** instead, which stays constant:

1. Find the container's subnet:

   ```bash
   docker ps -a
   docker exec -it <container-id> sh
   ip a
   ```

   You'll see the container's own loopback (irrelevant) plus an address like `172.32.0.5/16` — the `/16` is the subnet you want (`172.32.0.0/16`), since the container's specific IP is reassigned on every restart but the subnet is stable.
2. Add that subnet to the `allow` list of every internal `location` block n8n needs to reach (see the nginx configs referenced above).
3. Allow the subnet through UFW to the relevant internal port:

   ```bash
   sudo ufw allow from 172.32.0.0/16 to any port <internal-port> proto tcp
   ```
4. Since the container can't resolve the internal domain via DNS either, add it directly in `n8n.yaml`:

   ```yaml
   extra_hosts:
     - "domain.com:<private-ip-of-server>"
   ```

   (Already present in `n8n.yaml` as a template — fill in the real domain and IP.) You can skip this step if your router/local DNS (Pi-hole) already resolves the domain for every device on the network, container subnets included.

**When troubleshooting access to any service, ask in this order:**

1. Is the client (or container subnet) actually on a network path that can reach the internal port at all? (LAN, or [VPN](<../../Server set Up ( Do first )/6. vpn ( tailscale ).md>))
2. Is it allow-listed in nginx?
3. Is it allow-listed in UFW?
4. Can it resolve the domain name in the first place (local DNS, or `extra_hosts`)?
