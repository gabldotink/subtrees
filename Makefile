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
	make stop
	make remove
	make prepare
	make start

.PHONY: prepare
prepare:
	@mkdir $(mediawiki_dir); \
	cd $(mediawiki_dir); \
	git clone https://github.com/wikimedia/mediawiki.git . --depth=1; \
	echo "$$MW_ENV" > .env;

# "make remove" stops and removes mediawiki containers and files.
.PHONY: remove
remove:
	-@if [ -d "$(mediawiki_dir)" ]; then \
		read -p "Are you sure you want to delete mediawiki containers and EVERYTHING in \"$(mediawiki_dir)\" (y/n)? " -n 1 -r; \
		echo ; \
		if [ "$$REPLY" = "y" ]; then \
			make stop; \
			docker container rm mediawiki-elasticsearch-1; \
			docker container rm mediawiki-mediawiki-web-1; \
			docker container rm mediawiki-mediawiki-1; \
			docker container rm mediawiki-mediawiki-jobrunner-1; \
			rm -rf $(mediawiki_dir); \
			rm $(makefile_dir)/runonce; \
		fi; \
	fi

# "make stop" stops mediawiki containers.
.PHONY: stop
stop:
	-@cd $(mediawiki_dir); \
	docker compose down

# "make start" start mediawiki containers.
.PHONY: start
start: runonce
	@cd $(mediawiki_dir); \
	docker compose up -d; \
	sleep 1; \
	cd $(makefile_dir); \
	make openspecialversionpage;

runonce:
	-@cd $(mediawiki_dir); \
	docker compose up -d; \
	docker compose exec mediawiki composer update; \
	docker compose exec mediawiki bash /docker/install.sh; \
	docker compose down; \
	cd $(makefile_dir); \
	touch runonce; \
	make usevectorskin skipopenspecialversionpage=true;

# "make restart" restarts mediawiki containers.
.PHONY: restart
restart:
	make stop
	make start

# "make bashmw" for bash access to the mediawiki container.
.PHONY: bashmw
bashmw:
	cd $(mediawiki_dir); \
	docker compose exec mediawiki bash

# "make bashjr" for bash access to the job runner container.
.PHONY: bashjr
bashjr:
	cd $(mediawiki_dir); \
	docker compose exec mediawiki-jobrunner bash

# "make bashwb" for bash access to the web container.
.PHONY: bashwb
bashwb:
	cd $(mediawiki_dir); \
	docker compose exec mediawiki-web bash

.PHONY: applyskin
applyskin:
	@cd $(mediawiki_dir); \
	rm -rf "skins/$(skinDirectory)"; \
	git clone $(if $(skinBranch), --branch $(skinBranch),) $(skinRepoURL) "./skins/$(skinDirectory)" --depth=1; \
	cd $(makefile_dir); \
	sleep 1; \
	make applyskinsettings; \
	make openspecialversionpage;

.PHONY: applyskinsettings
applyskinsettings:
	@cd $(mediawiki_dir); \
	grep -qx '^wfLoadSkin.*$$' LocalSettings.php || echo 'wfLoadSkin("");' >> LocalSettings.php; \
	sed -i -E "s/^wfLoadSkin[[:blank:]]*\(([[:blank:]]*.*[[:blank:]]*)\)[[:blank:]]*;[[:blank:]]*$$/wfLoadSkin(\"$(wfLoadSkin)\");/g" LocalSettings.php; \
	sed -i -E "s/\\\$$wgDefaultSkin.*;[[:blank:]]*$$/\\\$$wgDefaultSkin = \"$(wgDefaultSkin)\";/g" LocalSettings.php;

.PHONY: usevectorskin
usevectorskin:
	make applyskin skinDirectory=Vector skinRepoURL=https://github.com/wikimedia/mediawiki-skins-Vector.git wfLoadSkin=Vector wgDefaultSkin=vector;

.PHONY: usedarkvectorskin
usedarkvectorskin:
	make applyskin skinDirectory=DarkVector skinRepoURL=https://github.com/jdlrobson/DarkVector.git skinBranch=24 wfLoadSkin=DarkVector wgDefaultSkin=darkvector;

.PHONY: useminervaneueskin
useminervaneueskin:
	make applyskin skinDirectory=MinervaNeue skinRepoURL=https://github.com/wikimedia/mediawiki-skins-MinervaNeue.git wfLoadSkin=MinervaNeue wgDefaultSkin=minerva;

.PHONY: usetimelessskin
usetimelessskin:
	make applyskin skinDirectory=Timeless skinRepoURL=https://github.com/wikimedia/mediawiki-skins-Timeless.git wfLoadSkin=Timeless wgDefaultSkin=timeless;

.PHONY: openspecialversionpage
openspecialversionpage:
	@if [ "$$skipopenspecialversionpage" != "true" ]; then \
		open "http://localhost:8080/wiki/Special:Version"; \
	fi

.PHONY: runparsertests
runparsertests:
	@cd $(mediawiki_dir); \
	docker compose exec mediawiki php tests/parser/parserTests.php;

.PHONY: runphpunittests
runphpunittests:
	cd $(mediawiki_dir); \
	docker compose exec --workdir /var/www/html/w/tests/phpunit mediawiki php phpunit.php $(if $(testpath), $(testpath),) $(if $(testgroup), --group $(testgroup),) --testdox;

installnode:
	cd $(mediawiki_dir); \
	docker compose exec mediawiki /bin/bash -c "curl -s https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash && source ~/.profile && nvm install node;"


.PHONY: applyextension
applyextension:
	@cd $(mediawiki_dir); \
	rm -rf "extensions/$(extensionDirectory)"; \
	git clone $(if $(extensionBranch), --branch $(extensionBranch),) $(extensionRepoURL) "./extensions/$(extensionDirectory)" --depth=1; \
	cd $(makefile_dir); \
	sleep 1; \
	make applyextensionsettings;

.PHONY: applyextensionsettings
applyextensionsettings:
	@cd $(mediawiki_dir); \
	grep -qx "^[[:blank:]]*wfLoadExtension[[:blank:]]*([[:blank:]]*[\"']$(wfLoadExtension)[\"'][[:blank:]]*)[[:blank:]]*;[[:blank:]]*$$" LocalSettings.php || echo 'wfLoadExtension("$(wfLoadExtension)");' >> LocalSettings.php;

.PHONY: cirrussetup
cirrussetup:
	@cd $(mediawiki_dir); \
	echo "\$$wgDisableSearchUpdate = true;" >> ./LocalSettings.php; \
	echo "\$$wgCirrusSearchServers = [ 'elasticsearch' ];" >> ./LocalSettings.php; \
	docker compose exec mediawiki php maintenance/update.php; \
	docker compose exec mediawiki composer --working-dir=/var/www/html/w/extensions/Elastica install; \
	docker compose exec mediawiki php extensions/CirrusSearch/maintenance/UpdateSearchIndexConfig.php; \
	sed -i '' '/\$wgDisableSearchUpdate = true;/d' ./LocalSettings.php; \
	docker compose exec mediawiki php extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipLinks --indexOnSkip; \
	docker compose exec mediawiki php extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipParse; \
	echo "\$$wgSearchType = 'CirrusSearch';" >> ./LocalSettings.php; \
	docker compose exec mediawiki php maintenance/runJobs.php

.PHONY: freshinstallwithcirrussearch
freshinstallwithcirrussearch:
	make stop;
	make remove;
	make prepare;
	cp ./docker-compose.override.yml $(mediawiki_dir)/docker-compose.override.yml;
	make start skipopenspecialversionpage=true;
	make applyextension extensionDirectory=Elastica extensionRepoURL=https://github.com/wikimedia/mediawiki-extensions-Elastica.git wfLoadExtension=Elastica;
	make applyextension extensionDirectory=CirrusSearch extensionRepoURL=https://github.com/wikimedia/mediawiki-extensions-CirrusSearch.git wfLoadExtension=CirrusSearch;
	make cirrussetup;
	sleep 5;
	make openspecialversionpage;
#	Open a url appending '&cirrusDumpQuery' to the Special:Search URL - should dump json containing the elasticsearch query if CirrusSearch is being used ( from https://www.mediawiki.org/wiki/Topic:Vspistlf132kafvm )
	open "http://localhost:8080/w/index.php?search=main+hastemplate%3Afoo&title=Special%3ASearch&go=Go&ns0=1&cirrusDumpQuery";
# 	Open a url searching for "main" - should show one result
	open "http://localhost:8080/w/index.php?search=main&title=Special%3ASearch&profile=default&fulltext=1";
