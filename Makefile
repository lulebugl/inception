#docker compose
ps:
	docker compose -f srcs/docker-compose.yml ps $(service)
down:
	docker compose -f srcs/docker-compose.yml down $(service)
up:
	docker compose -f srcs/docker-compose.yml up $(service) -d
build:
	docker compose -f srcs/docker-compose.yml build $(service)
rebuild: build up
restart:
	docker compose -f srcs/docker-compose.yml restart $(service)
clean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all $(service)
re:
	make clean
	make build
	make up

logs: 
	@docker compose -f srcs/docker-compose.yml logs $(service) | tail -n 100
enter:
	docker compose -f srcs/docker-compose.yml run --rm --no-deps --entrypoint bash $(service)
#utils
provision:
	bash scripts/provision.sh

share:
	sudo mkdir -p /mnt/src && \
    sudo mount -t vboxsf src /mnt/src && \
    sudo mount --bind /mnt/src .
