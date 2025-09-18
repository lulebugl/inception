#docker compose
ps:
	docker compose -f srcs/docker-compose.yml ps
down:
	docker compose -f srcs/docker-compose.yml down
up:
	docker compose -f srcs/docker-compose.yml up $(service) -d
build:
	docker compose -f srcs/docker-compose.yml build
clean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all
re:
	make clean
	make build
	make up

logs: 
	docker compose -f srcs/docker-compose.yml logs $(service) | tail -n 100

#utils
provision:
	bash scripts/provision.sh

share:
	sudo mkdir -p /mnt/src && \
    sudo mount -t vboxsf src /mnt/src && \
    sudo mount --bind /mnt/src .
