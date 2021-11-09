SHELL := /bin/bash

# This file is used to spin up a basic dockerized mediawiki instance on your local machine.
# Comments above the make commands below explain their usage.
# 
# For general info on Makefiles see: https://makefiletutorial.com but this Makefile is really
# just a convenient way to run some commands via simple "make" shortcuts. For a similar
# example see: https://github.com/graphql-python/graphene/blob/master/docs/Makefile

makefile_dir = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
mediawiki_dir = "$(makefile_dir)/mediawiki"

define MW_ENV
MW_DOCKER_PORT=8080
MW_DOCKER_UID=$(id -u)
MW_DOCKER_GID=$(id -g)
MEDIAWIKI_USER=Admin
MEDIAWIKI_PASSWORD=dockerpass
XDEBUG_ENABLE=true
XHPROF_ENABLE=true
XDEBUG_CONFIG=''
endef
export MW_ENV

# "make freshinstall" (or just "make") fetches, installs and runs a basic mediawiki container. Mediawiki gets saved in a "mediawiki" directory in the parent directory of the Makefile.
.DEFAULT: freshinstall
.PHONY: freshinstall
freshinstall:
	mkdir $(mediawiki_dir); \
	cd $(mediawiki_dir); \
	git clone https://github.com/wikimedia/mediawiki.git . --depth=1; \
	git clone https://github.com/wikimedia/mediawiki-skins-Vector.git ./skins/Vector --depth=1; \
	echo "$$MW_ENV" > .env; \
	docker compose up -d; \
	docker compose exec --user="root" mediawiki composer self-update --2; \
	docker compose exec --user="root" mediawiki composer update; \
	docker compose exec --user="root" mediawiki /bin/bash /docker/install.sh; \
	open "http://localhost:8080/wiki/Special:Version"

# "make remove" stops and removes mediawiki containers and files.
.PHONY: remove
remove:
	-@read -p "Are you sure you want to delete mediawiki containers and EVERYTHING in \"$(mediawiki_dir)\" (y/n)? " -n 1 -r; \
	echo ; \
	if [ "$$REPLY" = "y" ]; then \
		make stop; \
		docker container rm mediawiki-mediawiki-web-1; \
		docker container rm mediawiki-mediawiki-1; \
		docker container rm mediawiki-mediawiki-jobrunner-1; \
		rm -rf $(mediawiki_dir); \
	fi

# "make stop" stops mediawiki containers.
.PHONY: stop
stop:
	-cd $(mediawiki_dir); \
	docker compose down

# "make start" start mediawiki containers.
.PHONY: start
start:
	cd $(mediawiki_dir); \
	docker compose up -d; \
	open "http://localhost:8080/wiki/Special:Version"

# "make restart" restarts mediawiki containers.
.PHONY: restart
restart:
	make stop
	make start

# "make bashmw" for bash access to the mediawiki container.
.PHONY: bashmw
bashmw:
	docker exec -it mediawiki-mediawiki-1 /bin/bash

# "make bashjr" for bash access to the job runner container.
.PHONY: bashjr
bashjr:
	docker exec -it mediawiki-mediawiki-jobrunner-1 /bin/bash

# "make bashwb" for bash access to the web container.
.PHONY: bashwb
bashwb:
	docker exec -it mediawiki-mediawiki-web-1 /bin/bash