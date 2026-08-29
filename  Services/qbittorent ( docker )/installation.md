<p style="color:red; font-weight:bold; font-size:1.05em">WARNING: qBittorrent MUST run only on an isolated network with no access to client devices. Exception: you may mount a network storage device on another network only when the torrent server lacks sufficient storage — this is not recommended.</p>

_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

!!! DO AFTER REBOOTS !!!!
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

1) To mount MyFatNas for downloading torrents (do this after reboots):

```bash
sshfs user@server:/remote/location/of/server /local/location \
  -o allow_other \
  -o default_permissions \
  -o uid=your_network_mount's_id \
  -o gid=your_network_mount's_id
```

2) Then restart the qBittorrent stack so the container picks up the network mounted path (from `/path/docker-compose.yml`):

```bash
cd /path/docker-compose.yml
docker compose down && docker compose up -d
```

Reason: on boot the container starts before the network mount is ready. The container then sees the host path `/local/location` but not the mounted network filesystem under that path. After performing step 1 (mount), bring the container down and up so it picks up the mounted filesystem.

_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

!!! DO ONLY ONCE !!! NO NEED AFTER REBOOTS
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Make sure `/etc/fuse.conf` has `user_allow_other` enabled (do this only once; it persists across reboots). This allows the `allow_other` option in `sshfs` so the container user can write to the mount.

Why: by default the remote `/remote/location/of/server` mount forbids write access to "other" users for security (only R/X). Enabling `user_allow_other` lets the FUSE mount allow `other` access, then the mount command with `-o uid= your_network_mount's_id -o gid=your_network_mount's_id` restricts write access to the user with UID/GID `your_network_mount's_id` so qBittorrent can write safely.

To enable (example):

```bash
# Edit /etc/fuse.conf and ensure the following line is present and not commented:
user_allow_other
# No service restart needed; takes effect immediately for new mounts.
```

_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

How to find numeric UID/GID and verify the mount ownership and service user:

- Find the UID/GID owning the mounted directory:

```bash
stat -c '%U %G %u %g' /remote/location/of/server 
# or to get numeric only:
stat -c '%u %g' /remote/location/of/server 
```


Ensure `PUID`/`PGID` in your container compose file match the numeric owner you want the container process to run as.

Example `docker-compose` service snippet for `qbittorrent` (as used):

```yaml
qbittorrent:
  image: lscr.io/linuxserver/qbittorrent:latest
  container_name: qbittorrent
  environment:
    - PUID=your_network_mount's_id
    - PGID=your_network_mount's_id
    - TZ=Etc/UTC
    - WEBUI_PORT=8080
    - TORRENTING_PORT=6881
  volumes:
    - ./config:/config
    - /remote/location/of/server:/downloads
  ports:
    - "127.0.0.1:8080:8080"
    - "local_server_private_ip:6881:6881"
    - "local_server_private_ip:6881:6881/udp"
  restart: unless-stopped
```

_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Notes & tips:

- Always mount drives eather they are local or network mounts in `/mnt` . The permisions are relaxed for mounting drives.
- The 6881 tcp/udp ports are needed for torrents ports , so expose them to you whole Lan with the private ipv4 of the server (we don't want the ipv6). 
- The 8080 port is for the WebUI, so follow the `qbittorent` Nginx configuration: [nginx and cloudflare configurations/nginx configs/internal/qbittorent.conf](../../nginx%20and%20cloudflare%20configurations/nginx%20configs/internal/qbittorent.conf#L1).

_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________
