SHELL=/bin/bash
# Load variables
DATE := $(shell date +'%d-%m-%Y')
BACKUP_NAME := brain-backup
TMP_FOLDER := ./data/tmp
ENV_FILE = .env
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))
# DOCKER_REGISTRY is optional: empty uses Docker Hub, or set it to a private registry host
IMAGE_NAME := $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY)/,)$(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT)
# Docker commands
start:
	docker compose -p $(PROJECT_NAME) up -d
stop:
	docker compose -p $(PROJECT_NAME) down --remove-orphans
pause:
	docker compose -p $(PROJECT_NAME) pause
resume:
	docker compose -p $(PROJECT_NAME) unpause
# Backup (TODO: allow using custom tags)
load:
	@[ "$$(id -u)" = 0 ] || { echo "Run it as root: sudo make $@"; exit 1; }
	mkdir -p ./data/volumes
	rm -rf $(TMP_FOLDER)
	@docker rm -f $(BACKUP_NAME) >/dev/null 2>&1 || true
	docker pull $(IMAGE_NAME):$(PROJECT_NAME)-latest
	docker run -itd --name $(BACKUP_NAME) $(IMAGE_NAME):$(PROJECT_NAME)-latest
	docker cp $(BACKUP_NAME):/root/volumes $(TMP_FOLDER)
	docker kill $(BACKUP_NAME)
	docker rm $(BACKUP_NAME)
	make stop
	rm -rf ./data/volumes/*
	mv $(TMP_FOLDER)/brain/* ./data/volumes/.
	chown -R www-data:www-data ./data/volumes/wordpress
	find ./data/volumes/wordpress/ -type d -exec chmod 755 {} \;
	find ./data/volumes/wordpress/ -type f -exec chmod 644 {} \;
	chown -R www-data:www-data ./data/volumes/nextcloud
	find ./data/volumes/nextcloud/ -type d -exec chmod 755 {} \;
	find ./data/volumes/nextcloud/ -type f -exec chmod 644 {} \;
	chmod 770 ./data/volumes/nextcloud/data ./data/volumes/nextcloud/config ./data/volumes/nextcloud/custom_apps
	chmod 660 ./data/volumes/nextcloud/config/config.php
	make start
# Restore (TODO: allow select available tags)
save:
	@[ "$$(id -u)" = 0 ] || { echo "Run it as root: sudo make $@"; exit 1; }
	make pause
	@echo "Guardando en $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY),Docker Hub)..."
	docker build -t $(IMAGE_NAME):$(PROJECT_NAME)-latest -t $(IMAGE_NAME):$(PROJECT_NAME)-${DATE} .
	make resume
	docker push $(IMAGE_NAME):$(PROJECT_NAME)-latest
	docker push $(IMAGE_NAME):$(PROJECT_NAME)-${DATE}
test:
	echo ${DOCKER_HUB_USER}
logs:
	docker compose -p $(PROJECT_NAME) logs -f
clean:
	make stop
	rm ./data/volumes/* -rf
	make start
passwords:
	@bash passwords.sh
help:
	@echo "Usage:"
	@echo "  make start   - Start the system"
	@echo "  make stop    - Stop the system"
	@echo "  make save    - Backup system state to Docker Hub"
	@echo "  make load    - Restore system from backup"
	@echo "  make logs    - View system logs"
	@echo "  make clean   - Clean volumes and restart"
	@echo "  make passwords - Rotate the database passwords"