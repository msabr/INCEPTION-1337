# Developer Documentation

This document describes how a developer can set up, manage, and understand the technical details of the Inception project.

## Set up the Environment from Scratch
### Prerequisites
- A Linux virtual machine (e.g., Debian or Ubuntu).
- Docker Engine and Docker Compose V2 installed.
- `make` installed.

### Configuration & Secrets
1. Create a `srcs/.env` file. Do not commit this to version control.
2. Define the following environment variables in `.env`:
   - `DOMAIN_NAME=msabr.42.fr`
   - `DB_NAME`, `USER_NAME`, `DB_USER_PASS`, `DB_ROOT_PASSWORD` (for MariaDB setup)
   - `WP_AD_USER`, `WP_PS_USER`, `WP_USER_EMAIL` (for WordPress admin setup)
   - `WP_USER`, `WP_EMAIL`, `WP_PASS` (for a standard WordPress user)
3. Ensure `/etc/hosts` on your host machine maps your domain (`msabr.42.fr`) to `127.0.0.1`.

## Build and Launch the Project
The root `Makefile` handles orchestration:
- `make` or `make all`: Creates local directories for volumes, builds images using `docker-compose.yml`, and starts containers in detached mode (`-d`).
- `make clean`: Stops the running containers.
- `make fclean`: Stops and removes the containers.
- `make down`: Stops containers and removes all associated named volumes, completely resetting the project state.
- `make re`: Runs `make down` followed by `make all`.

## Manage Containers and Volumes
Use standard Docker Compose commands from the `srcs` directory (or point to the file using `-f`):
- Rebuild a specific image: `docker compose -f srcs/docker-compose.yml build <service>`
- Shell into a container: `docker exec -it <container_name> bash`
- List active volumes: `docker volume ls`

## Project Data Persistence
Data is persistently stored using Docker **named volumes** mapped to local directories on the host machine.
- **Database Storage**: MariaDB data persists in the `db_vol` volume, bound to `/home/msabr/data/db` on the host.
- **Website Files**: WordPress files persist in the `wp_vol` volume, bound to `/home/msabr/data/wp` on the host.

Even if the containers are destroyed, the data remains intact on the host machine inside the `/home/msabr/data/` directory until manually removed .
