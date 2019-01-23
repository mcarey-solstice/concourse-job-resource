# Concourse Job Resource Example
Run the make file to generate the three pipelines that should be run in order.

## Building the pipelines
1. Log into your concourse server via `fly -t ${FLY_TEAM} login -n ${FLY_TEAM}` where `FLY_TEAM` is the team being targeted.
2. Running `make FLY_TEAM=${FLY_TEAM}` to build, fly, and unpause all pipelines.
3. Trigger the `run-all-pipelines/run-pipeline-1` job: `fly -t ${FLY_TEAM} trigger-job -j run-all-pipelines/run-pipeline-1`.
