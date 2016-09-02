# Makefile for a harbor project
#	
# Targets:
#
# all, all_photon, all_ubuntu: 
#			prepare, compile, build images and install images (default: ubuntu)
# prepare: 		prepare env
# compile_all: 		compile ui and jobservice code
# compile_ui: 		compile ui code
# compile_jobservice: 	compile jobservice code
# build_db_ubuntu, build_log_ubuntu, build_jobservice_ubuntu, build_ui_ubuntu:
#			build harbor ubuntu images  
# build_db_photon, build_log_photon, build_jobservice_photon, build_ui_photon:
#			build harbor photon images
# build_db, build_log, build_jobservice, build_ui:
#			build harbor images  (default: ubuntu)
# build_ubuntu: 	build harbor ubuntu images
# build_photon: 	build harbor photon images
# install, install_ubuntu, install_photon:
# 			insatll harbor images (default: ubuntu)
# stop, stop_ubuntu, stop_photon: 
# 			stop harbor images (default: ubuntu)
# cleanbinary: 		clean ui and jobservice binary
# cleanimage, cleanimage_ubuntu, cleanimage_photon: 
# 			clean harbor images (default: ubuntu)
# clean, clean_ubuntu, clean_photon:
#			clean ui/jobservice binary and harbor images (default: ubuntu)

# common
BUILDPATH=$(CURDIR)
DEPLOYPATH=$(BUILDPATH)/Deploy
DOCKERCMD=$(shell which docker)
DOCKERCOMPOSECMD=$(shell which docker-compose)

# go parameters
GOCMD=$(shell which go)
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOINSTALL=$(GOCMD) install
GOTEST=$(GOCMD) test
GODEP=$(GOTEST) -i
GOFMT=gofmt -w

# binary 
UISOURCECODE=./ui
UIBINARYPATH=$(DEPLOYPATH)/ui
UIBINARYNAME=harbor_ui
JOBSERVICESOURCECODE=./jobservice
JOBSERVICEBINARYPATH=$(DEPLOYPATH)/jobservice
JOBSERVICEBINARYNAME=harbor_jobservice

# prepare parameters
PREPAREPATH=$(DEPLOYPATH)
PREPARECMD=prepare

# configfile
CONFIGPATH=$(DEPLOYPATH)
CONFIGFILE=harbor.cfg

# ubuntu dockerfile
DOCKERFILEPATH_UI_UBUNTU=$(DEPLOYPATH)/ui
DOCKERFILENAME_UI_UBUNTU=Dockerfile
DOCKERIMAGENAME_UI_UBUNTU=deploy_ui 
DOCKERFILEPATH_JOBSERVICE_UBUNTU=$(DEPLOYPATH)/jobservice
DOCKERFILENAME_JOBSERVICE_UBUNTU=Dockerfile
DOCKERIMAGENAME_JOBSERVICE_UBUNTU=deploy_jobservice
DOCKERFILEPATH_LOG_UBUNTU=$(DEPLOYPATH)/log
DOCKERFILENAME_LOG_UBUNTU=Dockerfile
DOCKERIMAGENAME_LOG_UBUNTU=deploy_log
DOCKERFILEPATH_DB_UBUNTU=$(DEPLOYPATH)/db
DOCKERFILENAME_DB_UBUNTU=Dockerfile
DOCKERIMAGENAME_DB_UBUNTU=deploy_db

# photon dockerfile
DOCKERFILEPATH_UI_PHOTON=$(DEPLOYPATH)/ui
DOCKERFILENAME_UI_PHOTON=Dockerfile.ui.photon
DOCKERIMAGENAME_UI_PHOTON=harbor_ui_photon
DOCKERFILEPATH_JOBSERVICE_PHOTON=$(DEPLOYPATH)/jobservice
DOCKERFILENAME_JOBSERVICE_PHOTON=Dockerfile.jobservice.photon
DOCKERIMAGENAME_JOBSERVICE_PHOTON=harbor_jobservice_photon
DOCKERFILEPATH_LOG_PHOTON=$(DEPLOYPATH)/log
DOCKERFILENAME_LOG_PHOTON=Dockerfile.log.photon
DOCKERIMAGENAME_LOG_PHOTON=harbor_log_photon
DOCKERFILEPATH_DB_PHOTON=$(DEPLOYPATH)/db
DOCKERFILENAME_DB_PHOTON=Dockerfile
DOCKERIMAGENAME_DB_PHOTON=harbor_db_photon

# docker-compose files
DOCKERCOMPOSEFILEPATH=$(DEPLOYPATH)
DOCKERCOMPOSEFILENAME_UBUNTU=docker-compose.yml
DOCKERCOMPOSEFILENAME_PHOTON=docker-compose.yml.photon

compile_ui:
	@echo "start building binary for ui..."
	$(GOBUILD) -o $(UIBINARYPATH)/$(UIBINARYNAME) $(UISOURCECODE)
	@echo "Done."
		
compile_jobservice:
	@echo "start building binary for jobservice..."
	$(GOBUILD) -o $(JOBSERVICEBINARYPATH)/$(JOBSERVICEBINARYNAME) $(JOBSERVICESOURCECODE)
	@echo "Done."

compile_all: compile_ui compile_jobservice

prepare:
	@echo "prepare..."
	$(PREPAREPATH)/$(PREPARECMD) -conf $(CONFIGPATH)/$(CONFIGFILE)
	
build_ui_ubuntu: 
	@echo "build ui container for ubuntu..."
	$(DOCKERCMD) build -f $(DOCKERFILEPATH_UI_UBUNTU)/$(DOCKERFILENAME_UI_UBUNTU) -t $(DOCKERIMAGENAME_UI_UBUNTU) .
	@echo "Done."
	
build_jobservice_ubuntu: 
	@echo "build jobservice container for ubuntu..."
	$(DOCKERCMD) build -f $(DOCKERFILEPATH_JOBSERVICE_UBUNTU)/$(DOCKERFILENAME_JOBSERVICE_UBUNTU) -t $(DOCKERIMAGENAME_JOBSERVICE_UBUNTU) .
	@echo "Done."
	
build_log_ubuntu:
	@echo "build log container for ubuntu..."
	cd $(DOCKERFILEPATH_LOG_UBUNTU) && $(DOCKERCMD) build -f $(DOCKERFILENAME_LOG_UBUNTU) -t $(DOCKERIMAGENAME_LOG_UBUNTU) .
	@echo "Done."
	
build_db_ubuntu:
	@echo "build db container for ubuntu..."
	cd $(DOCKERFILEPATH_DB_UBUNTU) && $(DOCKERCMD) build -f $(DOCKERFILENAME_DB_UBUNTU) -t $(DOCKERIMAGENAME_DB_UBUNTU) .
	@echo "Done."

build_ui_photon: compile_ui
	@echo "build ui container for photon..."
	$(DOCKERCMD) build -f $(DOCKERFILEPATH_UI_PHOTON)/$(DOCKERFILENAME_UI_PHOTON) -t $(DOCKERIMAGENAME_UI_PHOTON) .
	@echo "Done."
	
build_jobservice_photon: compile_jobservice
	@echo "build jobservice container for photon..."
	$(DOCKERCMD) build -f $(DOCKERFILEPATH_JOBSERVICE_PHOTON)/$(DOCKERFILENAME_JOBSERVICE_PHOTON) -t $(DOCKERIMAGENAME_JOBSERVICE_PHOTON) .
	@echo "Done."
	
build_log_photon: 
	@echo "build log container for photon..."
	cd $(DOCKERFILEPATH_LOG_PHOTON) && $(DOCKERCMD) build -f $(DOCKERFILENAME_LOG_PHOTON) -t $(DOCKERIMAGENAME_LOG_PHOTON) .
	@echo "Done."

build_db_photon: 
	@echo "build db container for photon..."
	cd $(DOCKERFILEPATH_DB_PHOTON) && $(DOCKERCMD) build -f $(DOCKERFILENAME_DB_PHOTON) -t $(DOCKERIMAGENAME_DB_PHOTON) .
	@echo "Done."
	
build_ui: build_ui_ubuntu
build_jobservice: build_jobservice_ubuntu
build_log: build_log_ubuntu
build_db: build_db_ubuntu

build_ubuntu: build_ui_ubuntu build_jobservice_ubuntu build_log_ubuntu build_db_ubuntu
build_photon: build_ui_photon build_jobservice_photon build_log_photon build_db_photon
build: build_ubuntu

install_ubuntu:
	@echo "install harbor based on ubuntu images..."
	$(DOCKERCOMPOSECMD) -f $(DOCKERCOMPOSEFILEPATH)/$(DOCKERCOMPOSEFILENAME_UBUNTU) up -d
	@echo "Done."

install_photon:
	@echo "install harbor based on photon images..."
	$(DOCKERCOMPOSECMD) -f $(DOCKERCOMPOSEFILEPATH)/$(DOCKERCOMPOSEFILENAME_PHOTON) up -d
	@echo "Done."

install: install_ubuntu

stop_ubuntu:
	@echo "stop harbor on ubuntu images..."
	$(DOCKERCOMPOSECMD) -f $(DOCKERCOMPOSEFILEPATH)/$(DOCKERCOMPOSEFILENAME_UBUNTU) stop
	@echo "Done."

stop_photon:
	@echo "stop harbor on photon images..."
	$(DOCKERCOMPOSECMD) -f $(DOCKERCOMPOSEFILEPATH)/$(DOCKERCOMPOSEFILENAME_PHOTON) stop
	@echo "Done."
	
stop: stop_ubuntu

cleanbinary:
	@echo "cleaning binary..."
	@if [ ! -d $(UIBINARYPATH)/$(UIBINARYNAME) ] ; then rm -rf $(UIBINARYPATH)/$(UIBINARYNAME) ; fi
	@if [ ! -d $(JOBSERVICEBINARYPATH)/$(JOBSERVICEBINARYNAME) ] ; then rm -rf $(JOBSERVICEBINARYPATH)/$(JOBSERVICEBINARYNAME) ; fi

cleanimage_ubuntu:
	@echo "cleaning image for ubuntu..."
	- docker rmi -f $(DOCKERIMAGENAME_UI_UBUNTU):latest
	- docker rmi -f $(DOCKERIMAGENAME_DB_UBUNTU):latest
	- docker rmi -f $(DOCKERIMAGENAME_JOBSERVICE_UBUNTU):latest
	- docker rmi -f $(DOCKERIMAGENAME_LOG_UBUNTU):latest
	- docker rmi -f registry:2.5.0
	- docker rmi -f nginx:1.9
	
cleanimage_photon:
	@echo "cleaning image for photon..."
	- docker rmi -f $(DOCKERIMAGENAME_UI_PHOTON):latest
	- docker rmi -f $(DOCKERIMAGENAME_DB_PHOTON):latest
	- docker rmi -f $(DOCKERIMAGENAME_JOBSERVICE_PHOTON):latest
	- docker rmi -f $(DOCKERIMAGENAME_LOG_PHOTON):latest
	- docker rmi -f registry:2.5.0
	- docker rmi -f nginx:1.9
	
cleanimage: cleanimage_ubuntu

clean: cleanbinary cleanimage
clean_photon: cleanbinary cleanimage_photon

all_ubuntu: prepare install_ubuntu
all_photon: prepare install_photon
all: all_ubuntu
