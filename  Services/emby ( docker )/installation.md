# Emby — Installation

## 1. Create the service directory

```bash
mkdir -p /root/Docker/emby
```

Place `emby.yaml` (see this folder) there.

## 2. Notes on `emby.yaml`

- Pick the correct image architecture for your hardware — see [Emby's Docker documentation](https://emby.media/docker-server.html).
- `volumes`:
  - `/root/Docker/emby/config:/config` — Emby's own config directory. It's created automatically the first time the container starts; you don't need to `mkdir` it yourself.
  - `/path/to/your_media:/mnt/media` — **change this** to wherever your media actually lives on the server. Mounting the whole `/media` directory is fine if that's simpler.
- `ports`: the host side (left of the colon) is the only thing you customize, and it must stay bound to `127.0.0.1` — never the server's LAN IP. See [Firewall (UFW)](<../../Server set Up ( Do first )/4. ufw ( firewall ).md>) for why. The container-side port (right of the colon) is Emby's own and shouldn't change.
- `devices`: `/dev/vchiq` is Raspberry Pi–specific (hardware video decode on that platform) — drop it if you're not running on a Pi.

## 3. Start the container

```bash
docker compose -f /root/Docker/emby/emby.yaml up -d
```

## 4. Fix config ownership

Emby must **not** run as root. After the first start, make sure the config directory it created is owned by your regular user (or `<user>:users`):

```bash
sudo chown -R <user>:users /root/Docker/emby/config
```

## 5. Reverse proxy

Add Emby's location block to your internal nginx config — see [`nginx configs/internal/internal_services.conf`](<../../nginx and cloudflare configurations/nginx configs/internal/internal_services.conf>) for the working example (`/emby/` → `http://127.0.0.1:8096/`).

## Optional: DLNA

DLNA needs to be enabled in Emby's own settings, and typically needs host networking or additional port/broadcast configuration beyond what's in `emby.yaml`. See Emby's own documentation before enabling it.
