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
	make pause
	rm ./data/volumes/* -r
	mv $(TMP_FOLDER)/brain/* ./data/volumes/.
	make resume
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
	rm ./src/volumes/* -rf
	make start
