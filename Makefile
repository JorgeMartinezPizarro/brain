SHELL=/bin/bash
# Load variables
DATE := $(shell date +'%d-%m-%Y')
BACKUP_NAME := brain-backup
ENV_FILE = .env
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))
# DATA_DIR holds the volumes outside the repo, e.g. /srv/<project>
$(if $(DATA_DIR),,$(error DATA_DIR is missing in .env - add DATA_DIR=/srv/$(PROJECT_NAME)))
VOLUMES := $(DATA_DIR)/volumes
TMP_FOLDER := $(DATA_DIR)/tmp
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
	mkdir -p $(VOLUMES)
	rm -rf $(TMP_FOLDER)
	@docker rm -f $(BACKUP_NAME) >/dev/null 2>&1 || true
	docker pull $(IMAGE_NAME):$(PROJECT_NAME)-latest
	docker run -itd --name $(BACKUP_NAME) $(IMAGE_NAME):$(PROJECT_NAME)-latest
	docker cp $(BACKUP_NAME):/root/volumes $(TMP_FOLDER)
	docker kill $(BACKUP_NAME)
	docker rm $(BACKUP_NAME)
	make stop
	rm -rf $(VOLUMES)/*
	mv $(TMP_FOLDER)/brain/* $(VOLUMES)/.
	rm -rf $(TMP_FOLDER)
	chown -R www-data:www-data $(VOLUMES)/wordpress
	find $(VOLUMES)/wordpress/ -type d -exec chmod 755 {} \;
	find $(VOLUMES)/wordpress/ -type f -exec chmod 644 {} \;
	chown -R www-data:www-data $(VOLUMES)/nextcloud
	find $(VOLUMES)/nextcloud/ -type d -exec chmod 755 {} \;
	find $(VOLUMES)/nextcloud/ -type f -exec chmod 644 {} \;
	chmod 770 $(VOLUMES)/nextcloud/data $(VOLUMES)/nextcloud/config $(VOLUMES)/nextcloud/custom_apps
	chmod 660 $(VOLUMES)/nextcloud/config/config.php
	make start
# Restore (TODO: allow select available tags)
save:
	@[ "$$(id -u)" = 0 ] || { echo "Run it as root: sudo make $@"; exit 1; }
	make pause
	@echo "Guardando en $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY),Docker Hub)..."
	docker build -f $(CURDIR)/Dockerfile -t $(IMAGE_NAME):$(PROJECT_NAME)-latest -t $(IMAGE_NAME):$(PROJECT_NAME)-${DATE} $(DATA_DIR)
	make resume
	docker push $(IMAGE_NAME):$(PROJECT_NAME)-latest
	docker push $(IMAGE_NAME):$(PROJECT_NAME)-${DATE}
test:
	echo ${DOCKER_HUB_USER}
logs:
	docker compose -p $(PROJECT_NAME) logs -f
clean:
	make stop
	rm -rf $(VOLUMES)/*
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
	@echo "  make passwords - Rotate the database and admin passwords"