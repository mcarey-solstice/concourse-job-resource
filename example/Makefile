#!/usr/bin/env make

FLY_TEAM ?= main

.PHONY: *

pipelines: pipeline-1 pipeline-2 pipeline-3 run-all-pipelines

pipeline-1: pipeline-1.yml
	fly -t $(FLY_TEAM) set-pipeline -p pipeline-1 -c pipeline-1.yml -n
	fly -t $(FLY_TEAM) unpause-pipeline -p pipeline-1

pipeline-2: pipeline-2.yml
	fly -t $(FLY_TEAM) set-pipeline -p pipeline-2 -c pipeline-2.yml -n
	fly -t $(FLY_TEAM) unpause-pipeline -p pipeline-2

pipeline-3: pipeline-3.yml
	fly -t $(FLY_TEAM) set-pipeline -p pipeline-3 -c pipeline-3.yml -n
	fly -t $(FLY_TEAM) unpause-pipeline -p pipeline-3

run-all-pipelines: run-all-pipelines.yml
	fly -t $(FLY_TEAM) set-pipeline -p run-all-pipelines -c run-all-pipelines.yml -n
	fly -t $(FLY_TEAM) unpause-pipeline -p run-all-pipelines

pipeline-1.yml:
	erb index=1 pipeline.yml.erb > pipeline-1.yml

pipeline-2.yml:
	erb index=2 pipeline.yml.erb > pipeline-2.yml

pipeline-3.yml:
	erb index=3 pipeline.yml.erb > pipeline-3.yml

run-all-pipelines.yml:
	erb run-all-pipelines.yml.erb > run-all-pipelines.yml

destroy:
	rm -f pipeline-1.yml pipeline-2.yml pipeline-3.yml
	fly -t $(FLY_TEAM) destroy-pipeline -p pipeline-1 -n
	fly -t $(FLY_TEAM) destroy-pipeline -p pipeline-2 -n
	fly -t $(FLY_TEAM) destroy-pipeline -p pipeline-3 -n
	fly -t $(FLY_TEAM) destroy-pipeline -p run-all-pipelines -n

# make ${target}
