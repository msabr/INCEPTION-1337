*This project has been created as part of the 42 curriculum by msabr.*

# Inception

## Description

**Inception** is a school project. The goal is to build a small website
by hand, using **Docker**, and run it inside a virtual machine.cleanclean

This project has 3 containers:

- **NGINX** – the front door, handles HTTPS
- **WordPress** – runs the website
- **MariaDB** – stores the website's data

Each image is built by hand, starting from `debian:bookworm`. No
ready-made images are allowed. This means we set up each part ourselves.

## Instructions

### What you need

- A Linux virtual machine
- Docker and Docker Compose
- `sudo` rights (to make folders for saving data)

### Setup

1. Clone the repo.
2. Make a `.env` file at the root of the project, next to the
   `Makefile`. It holds the passwords and settings. See `DEV_DOC.md`
   for the full list.
3. Make sure `msabr.42.fr` points to your machine (add it to
   `/etc/hosts` if needed).

### Build and run

```bash
make
```

This makes the data folders and starts all containers.

### Stop and clean

```bash
make clean
make fclean
make re
```

### Open the site

```
https://msabr.42.fr
```

The certificate is self-made, so the browser will show a warning. This
is normal. Click "continue" to go on.

More help:

- **`USER_DOC.md`** – how to use the site and the admin page
- **`DEV_DOC.md`** – how to build and manage the project

## Project description: Docker, files, and choices

### What Docker does here

Docker builds each part (NGINX, WordPress, MariaDB) as its own
**image**, using a `Dockerfile`. Then it runs each image as a
**container**. **Docker Compose** (`srcs/docker-compose.yml`) starts all
3 containers at once, puts them on one network, and links their
storage. One command starts (or stops) the whole website.

### Project files

```
.
├── DEV_DOC.md
├── Makefile
├── README.md
├── srcs
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements
│       ├── mariadb
│       │   ├── Dockerfile
│       │   └── tools
│       │       └── mariadb.sh
│       ├── nginx
│       │   ├── conf
│       │   │   └── nginx.conf
│       │   ├── Dockerfile
│       │   └── tools
│       │       └── nginx.sh
│       └── wordpress
│           ├── Dockerfile
│           └── tools
│               └── wordpress.sh
└── USER_DOC.md
```

Each `Dockerfile` starts with `FROM debian:bookworm`, adds only what is
needed, then runs a small script. That script sets things up once, then
keeps the main program running.

### Virtual Machines vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| What it is | A full fake computer, with its own OS | A small program that shares the host's OS |
| Start time | Slow (minutes) | Fast (seconds) |
| Uses | A lot of space and power | Very little |
| Isolation | Very strong | Good, but lighter |
| Use here | The whole project runs in one VM | Each part runs in its own container, inside that VM |

The VM keeps the project apart from your computer. Docker keeps each
part apart from the others, inside that VM. We use Docker because it is
fast and light.

### Secrets vs Environment Variables

- **Environment variables** are simple values sent to a container, like
  `DB_NAME=wordpress`. They are easy to use. But other people can see
  them with the command `docker inspect`.
- **Docker secrets** are files given only to the containers that need
  them. They are safer for passwords.

This project uses **environment variables**, from one `.env` file. This
file is not saved in Git. This is simple and works fine for a school
project. For a real website, Docker secrets would be safer.

### Docker Network vs Host Network

- With the **host network**, a container uses the same network as your
  computer. There is no wall between them. Ports can clash.
- With a **Docker network**, each container gets its own small network.
  It can find the others by name, without opening its doors to the
  outside.

This project uses one Docker network, called `inception`. All 3
containers share it. They find each other by name (`nginx`,
`wordpress`, `mariadb`), never by IP address. Only NGINX's door (port
443) is open to the outside. This is safer than the host network.

### Docker Volumes vs Bind Mounts

- A **named volume** is storage that Docker looks after by itself.
  Docker picks where the files live.
- A **bind mount** links a folder in the container to a folder you
  choose on your computer.

The school asks for the data to be saved in one exact place:
`/home/msabr/data/...`. To do that, and still use the `volumes:` part
of Docker Compose, this project uses **named volumes with bind-mount
settings** (`driver_opts: type: none, o: bind, device: ...`). It looks
like a normal volume in the compose file, but it acts like a bind
mount: you can see the files right on your computer, at a path you
know.

## Resources

### Where we learned things

- Docker docs — <https://docs.docker.com/>
- Docker Compose file reference — <https://docs.docker.com/compose/compose-file/>
- NGINX docs — <https://nginx.org/en/docs/>
- WordPress dev docs — <https://developer.wordpress.org/>
- WP-CLI docs — <https://wp-cli.org/>
- MariaDB docs — <https://mariadb.com/kb/en/>
- The 42 Inception subject PDF

### How AI was used

An AI assistant (Claude, by Anthropic) helped with:

- **Fixing bugs** — like WP-CLI not being found, MariaDB folder
  permission errors, and NGINX filling a shared folder before
  WordPress could.
- **Explaining ideas** — simple explanations of Docker networks,
  volumes vs bind mounts, and secrets vs env variables, used to write
  the tables in this README.
- **Writing these docs** — help to plan and write `README.md`,
  `USER_DOC.md`, and `DEV_DOC.md`, based on the real project files.

The Dockerfiles, the Compose file, and the scripts were written and
tested by hand. AI was only used to explain things and help write the
docs — not to write that code.