# Inception

## Config

`Makefile` and `srcs/.env` are already set for login **msabr**
(`DOMAIN_NAME=msabr.42.fr`). Everything else works out of the box, but
you should still open `srcs/.env` and change the generated passwords in
`secrets/*.txt` if you want your own.

## Build & run

```bash
chmod +x srcs/requirements/*/tools/*.sh
make            # build + up
make ps         # check container status
make logs       # tail all logs
```

Then add `msabr.42.fr` to `/etc/hosts` pointing at your VM's IP (or
`127.0.0.1` if testing locally), and visit `https://msabr.42.fr`.
You'll get a self-signed cert warning — that's expected and correct.

## What each piece does

- **mariadb** — Debian + `mariadb-server`, built from source, no prebuilt
  image. First boot creates the DB/user from the values in `secrets/`,
  then execs `mysqld` in the foreground as PID 1.
- **wordpress** — Debian + `php8.2-fpm` + WP-CLI. No NGINX inside this
  container. Installs WordPress non-interactively (you never see the
  5-minute install screen) and creates two users: an admin
  (`WP_ADMIN_USER`, deliberately not named "admin") and a regular
  `author`-role user for the "add a comment" grading step.
- **nginx** — Debian + `nginx` + `openssl`. Only port 443 is exposed.
  TLS 1.2/1.3 only, self-signed cert generated on first boot into a
  volume-less path inside the container (regenerated if the image is
  rebuilt, which is fine — grading doesn't require a persistent cert).

## Mapping to the grading sheet

- **Volumes**: `mariadb_data` → `/home/msabr/data/mariadb`,
  `wordpress_data` → `/home/msabr/data/wordpress` (bind mounts, check
  with `docker volume inspect mariadb_data`).
- **Network**: single custom bridge network `inception-network`
  (`docker network ls`).
- **Secrets**: DB and WP passwords are never in the Dockerfiles, `.env`,
  or `docker-compose.yml` — only the *paths* to `secrets/*.txt` are, via
  `_FILE` env vars read at container start.
- **Persistence**: since both volumes are host bind-mounts under
  `/home/msabr/data`, rebooting the VM and re-running `make up` reuses
  the same data — WordPress and MariaDB come back exactly as they were.
- **No infinite-loop/backgrounding entrypoints**: every entrypoint script
  ends in `exec <real-process>` running in the foreground as PID 1; the
  only `sleep` calls are short, bounded "wait until ready" polling loops
  during first-time setup, not permanent no-op loops.

## Useful commands during your own dry-run defense

```bash
docker compose -f srcs/docker-compose.yml ps
docker volume inspect mariadb_data | grep Device
docker network ls
curl -k https://msabr.42.fr          # should work
curl http://msabr.42.fr              # should fail/refuse
docker exec -it mariadb mysql -u root -p
docker exec -it wordpress wp user list --path=/var/www/html --allow-root
```
