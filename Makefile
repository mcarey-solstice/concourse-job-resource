###
# Project commands
##

# Variables

## Defaults
ENV_FILE ?= .env
PACKAGE_INFO ?= .package-info

DOCKER_SERVER =
DOCKER_USERNAME =
DOCKER_PASSWORD =

## Load the environment
ifneq (,$(wildcard $(ENV_FILE)))
	include $(ENV_FILE)
	export $(shell sed 's/=.*//' $(ENV_FILE))
endif

APP_NAME ?= $(shell grep 'APP_NAME = ' $(PACKAGE_INFO) | sed 's/APP_NAME = //g')
VERSION ?= $(shell grep 'VERSION = ' $(PACKAGE_INFO) | sed 's/VERSION = //g')

DOCKER_TAG ?= $(APP_NAME)

# Helpers

.PHONY: *

help:
	@echo "Usage: make <command>"
	@echo ""
	@echo "  Helpers:"
	@echo "    env               Creates the \`.env\` file from \`.env.example\`"
	@echo "    version           Prints the version of the package"
	@echo "    shell             Starts a shell in the docker image"
	@echo "    test              Runs the testing suite"
	@echo ""
	@echo "  Building:"
	@echo "    build             Builds the docker image"
	@echo "    build-nc          Builds the docker image without cache"
	@echo ""
	@echo "  Publishing:"
	@echo "    login             Logs the session into the docker hub"
	@echo "    release           Publishes the docker image to the docker hub"
	@echo "    publish           Publish the \`{version}\` and \`latest\` tagged containers"
	@echo "    publish-latest    Publish the \`latest\` taged container"
	@echo "    publish-version   Publish the \`{version}\` taged container"
	@echo ""
	@echo "  Tagging:"
	@echo "    tag               Generate container tags for the \`{version}\` and \`latest\` tags"
	@echo "    tag-latest        Generate container \`latest\` tag"
	@echo "    tag-version       Generate container \`{version}\` tag"
	@echo ""
# help

.DEFAULT_GOAL := help

.env:
	cp .env.example .env
# .env

env: .env

version:
	@echo $(VERSION)
# version

# Starts a shell in the docker image
shell: build .env
	docker run -it -v $(PWD):/srv -w /srv --env-file $(ENV_FILE) $(DOCKER_TAG) sh
# shell

test: build
	cd tests && ${MAKE} run
# test

# DOCKER TASKS

# Builds the docker image
build:
	docker build -t $(DOCKER_TAG) .
# build

# Builds the docker image without cache
build-nc:
	docker build --no-cache -t $(DOCKER_TAG) .
# build-nc

# Docker publish

LOGIN_CMD := "docker login"
ifneq (,$(DOCKER_USERNAME))
	LOGIN_CMD += " --username $(DOCKER_USERNAME)"
endif
ifneq (,$(DOCKER_PASSWORD))
	LOGIN_CMD += " --password $(DOCKER_PASSWORD)"
endif
ifneq (,$(DOCKER_SERVER))
	LOGIN_CMD += " $(DOCKER_SERVER)"
endif

login:
ifneq ("docker login",$(LOGIN_CMD))
	@eval $(LOGIN_CMD)
endif
# login

## Publishes the docker image to the docker hub
release: build-nc publish

## Publish the `{version}` and `latest` tagged containers
publish: login publish-latest publish-version

## Publish the `latest` taged container
publish-latest: tag-latest
	@echo 'publish latest to $(DOCKER_TAG)'
	docker push $(DOCKER_TAG):latest
# publish-latest

## Publish the `{version}` taged container
publish-version: tag-version
	@echo 'publish $(VERSION) to $(DOCKER_TAG)'
	docker push $(DOCKER_TAG):$(VERSION)
# publish-version

# Docker tagging

## Generate container tags for the `{version}` ans `latest` tags
tag: tag-latest tag-version

## Generate container `latest` tag
tag-latest:
	@echo 'create tag latest'
	docker tag $(DOCKER_TAG) $(DOCKER_TAG):latest
# tag-latest

## Generate container `{version}` tag
tag-version:
	@echo 'create tag $(VERSION)'
	docker tag $(DOCKER_TAG) $(DOCKER_TAG):$(VERSION)
# tag-version

# Makefile
