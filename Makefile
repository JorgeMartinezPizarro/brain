SHELL=/bin/bash
# Load variables
DATE := $(shell date +'%d-%m-%Y')
BACKUP_NAME := brain-backup
TMP_FOLDER := ./data/tmp
ENV_FILE = .env
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))
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
	rm -rf $(TMP_FOLDER)
	docker run -itd --name $(BACKUP_NAME) $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-latest
	docker cp $(BACKUP_NAME):/root/volumes $(TMP_FOLDER)
	docker kill $(BACKUP_NAME)
	docker rm $(BACKUP_NAME)
	make stop
	rm ./data/volumes/* -r
	mv $(TMP_FOLDER)/brain/* ./data/volumes/.
	chown -R www-data:www-data ./data/volumes/nextcloud
	find ./data/volumes/nextcloud/ -type d -exec chmod 755 {} \;
	find ./data/volumes/nextcloud/ -type f -exec chmod 644 {} \;
	chmod 770 ./data/volumes/nextcloud/data ./data/volumes/nextcloud/config ./data/volumes/nextcloud/custom_apps
	chmod 660 ./data/volumes/nextcloud/config/config.php
	make start
# Restore (TODO: allow select available tags)
save:
	make pause
	@echo "Guardando en Docker Hub..."
	docker build -t $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-latest -t $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-${DATE} .
	make resume
	docker push $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-latest
	docker push $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-${DATE}
test:
	echo ${DOCKER_HUB_USER}
logs:
	docker compose -p $(PROJECT_NAME) logs -f
clean:
	make stop
	rm ./data/volumes/* -rf
	make start
help:
	@echo "Usage:"
	@echo "  make start   - Start the system"
	@echo "  make stop    - Stop the system"
	@echo "  make save    - Backup system state to Docker Hub"
	@echo "  make load    - Restore system from backup"
	@echo "  make logs    - View system logs"
	@echo "  make clean   - Clean volumes and restart"