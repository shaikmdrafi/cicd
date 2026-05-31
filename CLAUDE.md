# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A minimal smoke-test project for a Jenkins → Docker Hub CI/CD pipeline. It builds a CentOS-based Apache (`httpd`) image whose only purpose is to serve a one-line `index.html` so the pipeline has something concrete to ship. There is **no application code, no tests, and no lint config** — the value of this repo is the pipeline wiring, not its contents.

## The pipeline

`Jenkinsfile` runs as a scripted (not declarative) pipeline with four stages:

1. **Clone repository** — `checkout scm`
2. **Build image** — `docker.build("rafi494/apachetest")` (uses `Dockerfile` at repo root)
3. **Test image** — intentionally a no-op (`sh 'echo "Tests passed"'`). The comment in the file flags this honestly as a "Volkswagen-type approach".
4. **Push image** — pushes to Docker Hub registry `rafi494/apachetest` with two tags: `${BUILD_NUMBER}` and `latest`. Uses Jenkins credentials ID **`docker-hub-credentials`** — this credential must exist in the Jenkins instance running the job.

`README.md` also documents an alternative **post-build shell snippet** (not used by `Jenkinsfile`) that the user runs from Jenkins post-build steps:

```bash
docker build -t testimage:$BUILD_NUMBER .
docker rm -f $(docker ps | grep test1 | awk '{print $1}')
docker run --name test1 -d -p 80:80 testimage
```

Note: that `docker run` references `testimage` (untagged → resolves to `:latest`) while the build only produces `testimage:$BUILD_NUMBER` — running this verbatim will fail unless an unrelated `testimage:latest` already exists locally. If asked to "fix the post-build commands", this is the bug.

## Building / running locally

```bash
# Build
docker build -t apachetest .

# Run (serves on http://localhost:80)
docker run --name apachetest -d -p 80:80 apachetest

# Tear down
docker rm -f apachetest
```

## Known issues to be aware of before editing

- **`FROM centos` is unpinned and EOL.** CentOS Linux 8 reached end-of-life in 2021 and the unversioned `centos` tag on Docker Hub points to retired content; `yum -y update` and `yum -y install httpd` will often fail with mirror/repo errors. If a build is failing, this is almost certainly why. Realistic fixes: switch base to `rockylinux:9`, `almalinux:9`, or `centos:stream9` (and adapt `yum` → `dnf` as needed).
- **`RUN echo ... >> index.html`** appends, but on a fresh httpd install `/var/www/html/index.html` doesn't exist yet — that's fine for `>>`, but anyone "fixing" this to `>` should be intentional about it.
- The Docker Hub push target (`rafi494/apachetest`) and credentials ID (`docker-hub-credentials`) are hardcoded in `Jenkinsfile`. Forking this pipeline to another account requires editing both.
