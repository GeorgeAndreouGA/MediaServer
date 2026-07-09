# Homer — Installation

Homer is a static dashboard that links out to every other service on the server.

## 1. Create the service directory

```bash
mkdir -p /root/Docker/homer
```

Place `homer.yaml` (see this folder) there.

## 2. Notes on `homer.yaml`

- `volumes`: `/root/Docker/homer/config:/www/assets` — Homer creates this directory automatically on first start; you don't need to `mkdir` it yourself.
- `ports`: stays bound to `127.0.0.1` — reached only through nginx, never directly. See [Firewall (UFW)](<../../Server set Up ( Do first )/4. ufw ( firewall ).md>).
- `user: 1000:1000` avoids Homer running as root inside the container.

## 3. Start the container

```bash
docker compose -f /root/Docker/homer/homer.yaml up -d
```

## 4. Configure the dashboard

Homer is driven entirely by `config/config.yml`, created under `/root/Docker/homer/config` after the first start (see this folder's `config/config.yml` for the working example: title, theme, and the service links themselves).

Add an entry under `services` for anything you want on the dashboard — icon (from [Font Awesome](https://fontawesome.com/search)), name, subtitle, and the URL it should link to.

## 5. Reverse proxy

Add Homer's location block to your internal nginx config — see [`nginx configs/internal/internal_services.conf`](<../../nginx and cloudflare configurations/nginx configs/internal/internal_services.conf>) for the working example (`/homer/` → `http://127.0.0.1:8080/`).
