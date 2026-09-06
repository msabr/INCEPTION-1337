LOGIN = msabr

all : 
	sudo mkdir -p /home/$(LOGIN)/data/db
	sudo mkdir -p /home/$(LOGIN)/data/wp
	docker compose -f srcs/docker-compose.yml up --build -d

clean :
	docker compose -f srcs/docker-compose.yml down

fclean: clean
	docker compose -f srcs/docker-compose.yml down -v --rmi all
	sudo rm -rf /home/$(LOGIN)/data/db
	sudo rm -rf /home/$(LOGIN)/data/wp

re : fclean all