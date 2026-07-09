# Portainer — Installation

Portainer gives a web UI for managing Docker on this host: containers, images, volumes, networks, and compose stacks.

> **This is a Docker admin console — treat it like one.** There is no DMZ config for it: it's reachable only through the internal nginx server, gated to LAN/VPN IPs, per the [reverse proxy architecture](<../../nginx and cloudflare configurations/6. reverse proxy architecture ( dmz + internal ).md>) golden rule. See `nginx configs/internal/portainer_nginx.conf`.

## 1. Create the service directory

```bash
mkdir -p /root/Docker/portainer
```

Place `portainer.yaml` (see this folder) there.

## 2. Notes on `portainer.yaml`

- The container mounts `/var/run/docker.sock` to manage Docker — this is equivalent to root on the host. Never bind its port anywhere but `127.0.0.1`; nginx plus the LAN/VPN allow-list are the only things standing between Portainer and the internet.
- Data (users, settings, stack definitions) persists in `./data`.

## 3. Start the container

```bash
docker compose -f /root/Docker/portainer/portainer.yaml up -d
```

## 4. Reverse proxy

1. In Cloudflare, create a `portainer.<your-domain>` subdomain record with the proxy toggle **off** (internal-only — see [Domain & SSL setup](<../../nginx and cloudflare configurations/5. setting a domain name with ssl cert.md>)).
2. Issue it a certificate via sslfree.io and install it under `/etc/sslfree/portainer.<your-domain-without-tld>/`.
3. Use `nginx configs/internal/portainer_nginx.conf` as the site config, then:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

## 5. First login

From an allow-listed LAN/VPN client, open `https://portainer.<your-domain>` and create the initial admin account. Portainer only allows this for a short window after the container's first start — if you miss it, the setup locks and you'll need to recreate the container.

## 6. Connect the local Docker environment

On first login, choose the local Docker environment. Since `docker.sock` is already mounted, Portainer immediately sees every container on this host — no agent needed.
