SHELL=/bin/bash
# Load variables
DATE := $(shell date +'%d-%m-%Y')
BACKUP_NAME := brain-backup
TMP_FOLDER := ./tmp
ENV_FILE = .env
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))
# Docker commands
start:
	cd src && docker compose -p $(PROJECT_NAME) up -d
stop:
	cd src && docker compose -p $(PROJECT_NAME) down --remove-orphans
pause:
	cd src && docker compose -p $(PROJECT_NAME) pause
resume:
	cd src && docker compose -p $(PROJECT_NAME) unpause
# Backup (TODO: allow using custom tags)
load:
	rm -rf $(TMP_FOLDER)
	docker run -itd --name $(BACKUP_NAME) $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-latest
	docker cp $(BACKUP_NAME):/root/volumes $(TMP_FOLDER)
	docker kill $(BACKUP_NAME)
	docker rm $(BACKUP_NAME)
	make pause
	rm src/volumes/* -rf
	mv $(TMP_FOLDER)/brain/* ./src/volumes/.
	make resume
# Restore (TODO: allow select available tags)
save:
	make pause
	@echo "Guardando en Docker Hub..."
	cd src && docker build -t $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-latest -t $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-${DATE} .
	make resume
	docker push $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-latest
	docker push $(DOCKER_HUB_USER)/$(DOCKER_HUB_PROJECT):$(PROJECT_NAME)-${DATE}
