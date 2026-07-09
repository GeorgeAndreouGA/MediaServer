# Zabbix — Installation (Bare Metal)

Unlike the other services in this repo, Zabbix runs directly on the host rather than in Docker — it's the monitoring system watching everything else, so it shouldn't share a failure domain (or a restart) with the thing being monitored.

## Install

- **Server:** [zabbix.com/download](https://www.zabbix.com/download) — pick your OS, Zabbix version, and MySQL/MariaDB (MariaDB, not MySQL — Oracle's MySQL apt repo doesn't reliably ship arm64 builds, which matters on a Raspberry Pi). Follow the page's own steps exactly; it already includes a local Zabbix agent alongside the server, so nothing further is needed to monitor this host itself.
- **Agent, for any *other* host you want to monitor:** [zabbix.com/download_agents](https://www.zabbix.com/download_agents). Skip this until you actually have a second host to add.

Everything below is what's specific to *this* setup — the download pages already cover the generic install.

## Why this needs three separate listeners, each locked down differently

Zabbix isn't one service — it's three, and they have fundamentally different audiences:

| Listener                              | Port  | Who needs to reach it                                          | Bind address                  |
| ------------------------------------- | ----- | -------------------------------------------------------------- | ----------------------------- |
| Web UI (Zabbix's own frontend)        | 10052 | LAN/VPN clients, via the existing reverse proxy                | `127.0.0.1` only            |
| Local agent (bundled with the server) | 10050 | Only the Zabbix server process itself, monitoring its own host | `127.0.0.1` only            |
| Zabbix server's own listener          | 10051 | Remote agents on*other* hosts, reporting in                  | This server's real LAN/VPN IP |

**The web UI** is plain HTTP, so it fits the same reverse-proxy pattern used for every other service in this repo: Zabbix's own frontend (`/etc/zabbix/nginx.conf`) listens on `127.0.0.1:10052` directly, and `nginx configs/internal/internal_services.conf`'s `/monitor/` location proxies straight to it — one hop, same as Emby/Homer, just with Zabbix's own package config standing in for a Docker container's exposed port.

**The local agent and the server's remote-facing listener are not HTTP** — they speak Zabbix's own binary protocol. **nginx's `proxy_pass` only understands HTTP(S)**, so there's no `location` block that can front a raw TCP protocol like this one. So:

- The **local agent** (10050) only ever needs to answer the Zabbix server on this same host — bind it to `127.0.0.1`, it never touches nginx or UFW.
- The **server's own listener** (10051) *does* need to accept connections from other hosts' agents. Since nginx can't gatekeep it, that's UFW's job directly on port 10051, restricted to the specific hosts you're monitoring — see [Firewall (UFW)](<../../Server set Up ( Do first )/4. ufw ( firewall ).md>) for the allow-list pattern this follows.

## Localhost config files

Four files need editing after install, all toward the same goal: nothing here ever binds to the LAN IP except the one port UFW explicitly allow-lists.

**`/etc/zabbix/zabbix_server.conf`** — the server process:

```
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=<your db password>
ListenIP=<this server's real LAN or VPN IP>   # NOT 127.0.0.1 — remote agents connect here (see UFW note above)
```

**`/etc/zabbix/zabbix_agent2.conf`** — the local, bundled agent monitoring this host:

```
Server=127.0.0.1
ServerActive=127.0.0.1
ListenIP=127.0.0.1
Hostname=Zabbix server
```

**`/etc/zabbix/nginx.conf`** — Zabbix's own package-provided frontend config (not something we author ourselves — it ships commented out and just needs uncommenting/setting):

```
listen 127.0.0.1:10052;
server_name <your_domain>;
```

This is the exact port `internal_services.conf`'s `/monitor/` location already proxies to — set it here to match, and there's nothing else to change on the nginx side.

**`/etc/zabbix/php-fpm.conf`** — the frontend's PHP-FPM pool:

```
php_value[date.timezone] = <Your/Timezone>
```

## Reverse proxy

Already wired up in [`nginx configs/internal/internal_services.conf`](<../../nginx and cloudflare configurations/nginx configs/internal/internal_services.conf>) — its `/monitor/` location already proxies to `127.0.0.1:10052`. See [Reverse Proxy Architecture](<../../nginx and cloudflare configurations/6. reverse proxy architecture ( dmz + internal ).md>) for how that fits into the DMZ/internal split generally.

## Monitoring another host

1. On that host, install just the agent from [zabbix.com/download_agents](https://www.zabbix.com/download_agents).
2. Point it at this server: `Server=<this-server's-IP>` and `ServerActive=<this-server's-IP>` in its `zabbix_agent2.conf` (active checks — the default — mean the agent connects out to the server, not the other way around).
3. Allow-list that host's IP through UFW on port 10051 on zabix server (see the UFW link above).
4. Add the host in the Zabbix web UI (**Data collection → Hosts**) and attach a template.
