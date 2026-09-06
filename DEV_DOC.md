# Developer Documentation

This page tells a developer how to set up, build, and manage this
project.

## 1. Setting up from scratch

### What you need

- A Linux virtual machine
- Docker
- Docker Compose plugin (`docker compose`, not the old `docker-compose`)
- `sudo` rights (the Makefile makes folders under `/home`)

### Files you should know

| File | What it's for |
|---|---|
| `Makefile` | Start / stop / clean commands |
| `.env` | All settings and passwords (you make this file; it is not in Git) |
| `srcs/docker-compose.yml` | The 3 services, the network, and storage |
| `srcs/requirements/<service>/Dockerfile` | How to build each container |
| `srcs/requirements/<service>/tools/*.sh` | The script each container runs at start |

### Making the `.env` file

Make a `.env` file at the project root, next to the `Makefile`:

```env
# MariaDB
DB_NAME=wordpress
DB_USER=msabrdb
DB_USER_PASS=1234

URL=msabr.42.fr

WP_ADMIN_USER=msabrwp
WP_ADMIN_PASS=1234
WP_ADMIN_EMAIL=msabrwp@localhost.mail

WP_USER_NAME=user
WP_USER_EMAIL=user@localhost.mail
WP_USER_PASS=1234
```

### About secrets

This project reads all these values as **environment variables**, sent
in with `env_file: .env` in `docker-compose.yml`. Nothing is written
inside a Dockerfile by hand. Put `.env` in `.gitignore` so it never
goes into Git. Check the "Secrets vs Environment Variables" part of
`README.md` for why Docker secrets could be safer for a real website.

## 2. Build and run with the Makefile and Docker Compose

### Makefile commands

| Command | What it does |
|---|---|
| `make` / `make all` | Makes `/home/msabr/data/{db,wp}`, then runs `docker compose -f srcs/docker-compose.yml up --build -d` |
| `make clean` | Runs `docker compose ... stop` — stops the containers, keeps the data |
| `make fclean` | `clean`, then removes containers, storage and images, and deletes the data folders |
| `make re` | `fclean`, then `all` — full rebuild |

### Using Docker Compose by hand

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
docker compose -f srcs/docker-compose.yml down
```

## 3. Commands for containers and storage

**Containers:**

```bash
docker compose -f srcs/docker-compose.yml ps
docker ps -a

docker logs nginx
docker logs wordpress
docker logs mariadb

docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

docker exec -it mariadb mysql -u root
```

**Network:**

```bash
docker network ls
docker network inspect inception
```

**Storage:**

```bash
docker volume ls
docker volume inspect srcs_db_vol
docker volume inspect srcs_wp_vol
```

**Rebuild only one part** (good while you are working on it):

```bash
docker compose -f srcs/docker-compose.yml up -d --build wordpress
```

## 4. Where the data is, and how it stays safe

Two storage spots are set in `docker-compose.yml`. Both point to one
exact folder on your computer (see "Docker Volumes vs Bind Mounts" in
`README.md` for why):

| Storage | Folder on your computer | Used in | What's inside |
|---|---|---|---|
| `db_vol` | `/home/msabr/data/db` | `mariadb` → `/var/lib/mysql` | All database files |
| `wp_vol` | `/home/msabr/data/wp` | `wordpress` and `nginx` → `/var/www/html/wordpress` | WordPress files, themes, uploads, `wp-config.php` |

These folders live on your computer, not just inside a container. So
the data stays safe through:

- restarting a container
- `make clean`
- restarting the virtual machine, then running `make` again

Data is deleted only with `make fclean` (or `make re`, which runs
`fclean` first). That command removes the folders under
`/home/msabr/data`.

> Docker does not fix the owner of a bind-mounted folder by itself. If
> MariaDB will not start and shows a permission error, check that
> `/home/msabr/data/db` is owned by the `mysql` user (UID/GID `999`)
> inside the container.

## 5. Common problems

| What you see | What to check |
|---|---|
| Site does not load at all | Is `nginx` running? `docker logs nginx` |
| "502 Bad Gateway" | Is `wordpress` running and listening on port 9000? `docker exec wordpress ss -tuln \| grep 9000` |
| WordPress setup page shows up | The install step in `wordpress.sh` did not finish. Check `docker logs wordpress` |
| Database errors | Check that `DB_NAME` / `DB_USER` / `DB_USER_PASS` are the same in MariaDB and in WordPress |
| Data is gone after a rebuild | Check that `/home/msabr/data/db` and `/home/msabr/data/wp` still exist and were not removed by `fclean` |