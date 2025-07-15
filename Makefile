NAME := inception
DC := docker compose
DC_FILE := ./srcs/docker-compose.yml

.PHONY: all up down build clean fclean restart logs ps

all: up

up:
	@echo " Starting all services...."
	@$(DC) -f $(DC_FILE) up -d

down:
	@echo "Stopping all services..."
	@$(DC) -f $(DC_FILE) down

build:
	@echo "Building all docker images...."
	@$(DC) -f $(DC_FILE) build

clean:
	@echo "Stopping and removing containers..."
	@$(DC) -f $(DC_FILE) down
	
fclean: clean
	@echo "Removing Docker volumes and images..."
	docker volume prune -f
	docker image prune -a -f

restart: down up

logs:
	@echo "Showing logs...."
	@$(DC) -f $(DC_FILE) logs
	
ps:
	@echo "Docker containers status"
	@$(DC) -f $(DC_FILE) ps

