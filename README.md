# Inception

A small infrastructure of 3 Docker containers — NGINX, WordPress (PHP-FPM),
and MariaDB — each built from its own Dockerfile, wired together with
Docker Compose.

## Requirements

- A Linux VM (or similar) with Docker and the Docker Compose plugin installed.
- You must be able to write to `/home/msabr` (see "First-time setup" below).

## First-time setup

The project stores all real data at `/home/msabr/data`. That path only
works if you're logged in as `msabr`, or if it's been created and handed
to you with the right owner. Run this once:

```bash
sudo mkdir -p /home/msabr/data
sudo chown -R msabr:msabr /home/msabr/data
```

Make the startup scripts executable (only needed once, or if you re-clone):

```bash
chmod +x srcs/requirements/*/tools/*.sh
```

## Build and run

```bash
make
```

This creates the two data folders (`data/mariadb`, `data/wordpress`) and
runs `docker compose up --build -d`.

Check it worked:

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three containers (`mariadb`, `wordpress`, `nginx`) should say `Up`.

## View the site

Add this line to `/etc/hosts` on the machine you're browsing from
(pointing at your VM's IP — use `127.0.0.1` if you're testing locally):

```
127.0.0.1   msabr.42.fr
```

Then open `https://msabr.42.fr` in a browser. You'll get a certificate
warning first — that's expected, since it's a self-signed certificate,
not a real trusted one.

- `http://msabr.42.fr` should **fail to connect** (only port 443 is open).
- `https://msabr.42.fr` should show your WordPress site directly —
  never the WordPress installation wizard.

## Makefile commands

| Command      | What it does                                              |
|--------------|------------------------------------------------------------|
| `make`       | Build the images and start all 3 containers               |
| `make down`  | Stop and remove the containers (keeps your data)           |
| `make clean` | Same as `down`, plus deletes the stored data               |
| `make re`    | `clean` then `make` — full reset and rebuild from scratch  |

## Project layout

```
inception/
├── Makefile
├── secrets/                       # passwords, read by containers at startup
│   ├── db_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/bind.cnf      # lets MariaDB accept network connections
        │   └── tools/init_db.sh   # creates the DB + user on first boot
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf.template
        │   └── tools/start.sh     # generates the TLS cert, starts nginx
        └── wordpress/
            ├── Dockerfile
            ├── conf/www.conf      # PHP-FPM pool config
            └── tools/start.sh     # installs WordPress via WP-CLI on first boot
```

## Logging in

- **WordPress admin**: username is `superuser` (deliberately doesn't
  contain "admin"), password in `secrets/wp_admin_password.txt`.
- **WordPress regular user**: username `editor`, password in
  `secrets/wp_user_password.txt` — used to test adding a comment as a
  non-admin.
- **MariaDB**, to inspect the database directly:
  ```bash
  docker exec -it mariadb mysql -u root
  ```
  No password needed for `root` here — MariaDB on Debian trusts the
  container's own root user automatically (Unix socket authentication).
  To log in as the WordPress database user instead:
  ```bash
  docker exec -it mariadb mysql -u wp_user -p
  # password is in secrets/db_password.txt
  ```

## Why things are set up this way

- **Each container ends its startup script with `exec <process>`** so
  that process becomes PID 1 running in the foreground — no background
  daemons, no infinite `sleep`/`tail -f` loops.
- **Passwords never appear in any Dockerfile or in `docker-compose.yml`**
  — only the *path* to a secret file does; the real value is read from
  disk at container startup.
- **Data volumes are host bind-mounts** (`/home/msabr/data/...`), not
  Docker's internal volume storage, so a VM reboot + `make` doesn't lose
  anything.
- **All three images are built `FROM debian:bookworm`** — no
  pre-built `nginx`, `wordpress`, or `mariadb` images from Docker Hub.

## Troubleshooting

```bash
docker compose -f srcs/docker-compose.yml logs -f          # all logs
docker logs mariadb
docker logs wordpress
docker logs nginx
```

If a container keeps restarting, its log will usually show the exact
line that failed — paste it back for help rather than guessing.
