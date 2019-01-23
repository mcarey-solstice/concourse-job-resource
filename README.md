# Concourse Job Resource

Get and set concourse pipeline jobs from concourse.

## Installing

Use this resource by adding the following to
the `resource_types` section of a pipeline config:

```yaml
---
resource_types:
- name: concourse-job
  type: docker-image
  source:
    repository: mcareysolstice/concourse-job-resource
```

See [concourse docs](https://concourse-ci.org/resource-types.html) for more details
on adding `resource_types` to a pipeline config.

## Source configuration

Check returns the version of a job. Configure as follows:

```yaml
---
resources:
- name: my-job
  type: concourse-pipeline
  source:
    target: https://my-concourse.com
    insecure: "false"
    team: team-1
    username: some-user
    password: some-password
    pipeline: my-pipeline
    job: my-job
    status: succeeded
```

* `target`: *Optional.* URL of your concourse instance e.g. `https://my-concourse.com`.
  If not specified, the resource defaults to the `ATC_EXTERNAL_URL` environment variable,
  meaning it will always target the same concourse that created the container.

* `insecure`: *Optional.* Connect to Concourse insecurely - i.e. skip SSL validation.
  Must be a [boolean-parseable string](https://golang.org/pkg/strconv/#ParseBool).
  Defaults to "false" if not provided.

* `team`: *Required.* Name of team.
  Equivalent of `-n team-name` in `fly login` command.

* `username`: Basic auth username for logging in to the team.
  If this and `password` are blank, team must have no authentication configured.

* `password`: Basic auth password for logging in to the team.
  If this and `username` are blank, team must have no authentication configured.

## `in`: Get the configuration of the pipelines

Get the version for the pipeline job; write it to the local working directory (e.g.
`/tmp/build/get`) with the filename derived from the JSON output.

For example, if the job build outputs `{"id": 345, "api_url": "/api/v1/builds/345", ...}`, an `id` file will have the contents: `345`, an `api_url` file will have the contents: `/api/v1/builds/345`, etc.

```yaml
---
resources:
- name: my-job
  type: concourse-job
  source: ...

jobs:
- name: get-my-job-version
  plan:
  - get: my-job
```

## `out`: Set the configuration of the pipelines

Triggers the job for a new build.

```yaml
---
resources:
- name: my-pipelines
  type: concourse-pipeline
  source: ...

jobs:
- name: trigger-my-job
  plan:
  - put: my-job
```
