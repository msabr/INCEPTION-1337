NAME		= inception

LOGIN		= msabr

DATA_DIR	= /home/$(LOGIN)/data
COMPOSE_FILE	= srcs/docker-compose.yml
COMPOSE		= docker compose -f $(COMPOSE_FILE)

.PHONY: all build up down stop start restart clean fclean re logs ps

all: build up

# Data directories must exist before the volumes bind-mount to them.
$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) build

up: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

# Removes containers/images/networks but keeps volume data on disk.
clean: down
	docker system prune -af

# Full wipe: containers, images, volumes, and the bind-mounted data itself.
fclean: clean
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

re: fclean all
