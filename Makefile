LOGIN = msabr

all : 
	sudo mkdir -p /home/$(LOGIN)/data/db
	sudo mkdir -p /home/$(LOGIN)/data/wp
	docker compose -f srcs/docker-compose.yml up --build -d
clean :
	docker compose -f srcs/docker-compose.yml stop
fclean : clean
	docker compose -f srcs/docker-compose.yml rm -f 

down: fclean
	docker compose -f srcs/docker-compose.yml down -v 
	sudo rm -rf /home/$(LOGIN)/data/db
	sudo rm -rf /home/$(LOGIN)/data/wp

re : down all