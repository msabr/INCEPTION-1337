# This project stores data at /home/msabr/data — that only works if you are
# actually logged in as msabr, or if you create /home/msabr once with sudo.
# (That's what caused the "Permission denied" error you hit earlier.)

LOGIN = msabr
# The two folders where MariaDB and WordPress will store their real files
# (outside the containers, so data survives `docker compose down` and reboots).
DATA  = /home/$(LOGIN)/data

all:
	mkdir -p $(DATA)/mariadb $(DATA)/wordpress
	# Create the two data folders first (docker can't create /home/$(LOGIN)/... itself).
	docker compose -f srcs/docker-compose.yml up --build -d
	# --build : rebuild images from our Dockerfiles
	# -d      : run in the background (detached)

down:
	docker compose -f srcs/docker-compose.yml down
	# Stops and removes the 3 containers (keeps the data on disk).

clean: down
	sudo rm -rf $(DATA)
	# Also deletes the stored data itself. Needs sudo because the containers
	# wrote those files as root/mysql/www-data, not as your user.

re: clean all
	# Full reset: wipe everything, then build and start again from scratch.
