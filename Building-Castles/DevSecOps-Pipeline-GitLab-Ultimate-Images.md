# Lab | GitLab Ultimate container image management

In this lab you will understand how GitLab Ultimate manages, scan and stores
container images coming from the pipelines.

## Where does GitLab stores images

GitLab Ultimate by default comes with a Container Registry, a secure and private
registry for container images. It’s built on open source software and completely
integrated within GitLab.

One way to understand where the Container Registry lives is by looking at the
content of these environmental variables that are passed in every pipeline run:

| Variable	       | Meaning                             |
|----------------------|-------------------------------------|
| CI_REGISTRY          | Registry address                    |
| CI_REGISTRY_IMAGE    | Complete path of the produced image |
| CI_REGISTRY_USER     | Registry user                       |
| CI_REGISTRY_PASSWORD | Temporary pipeline registry token   |
| CI_COMMIT_SHA        | Commit SHA                          |

## Container build

Create a `Dockerfile` inside `myproject` with these contents:

```dockerfile
FROM alpine:3.10

ENV NCAT_MESSAGE "Container test"
ENV NCAT_HEADER "HTTP/1.1 200 OK"
ENV NCAT_PORT "8888"

RUN addgroup -S nonroot && \
    adduser -S nonroot -G nonroot

USER nonroot

CMD /usr/bin/nc -l -k -p ${NCAT_PORT} -e /bin/echo -e "${NCAT_HEADER}\n\n${NCAT_MESSAGE}"
```

Add the build process to the pipeline adding to `.gitlab-ci.yml` this code:

```yaml
variables:
  ...
  CS_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

stages:
  - build
  - test

build-image:
  stage: build
  script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    - docker build -t "$CS_IMAGE" .
    - docker push "$CS_IMAGE"

sast:
  stage: test
```

Before the commit and push, a new branch should be created, so that it will be
possible to create the merge request:

```console
$ git branch
  activate-ci
  first-test
* main

$ git checkout -b add-container-build
Switched to a new branch 'add-container-build'
```

Then it will be possible to commit and push as follows:

```console
$ git add . && git commit -m "Add container build and push"
[main 113b719] Add container build and push
 2 files changed, 31 insertions(+)
 create mode 100644 Dockerfile

$ git push --set-upstream origin add-container-build
Warning: Permanently added '[172.16.99.1]:2222' (ED25519) to the list of known hosts.
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: 
remote: To create a merge request for add-container-build, visit:
remote:   http://3ce87b50f761/building-castles/myproject/-/merge_requests/new?merge_request%5Bsource_branch%5D=add-container-build
remote: 
To ssh://172.16.99.1:2222/building-castles/myproject.git
 * [new branch]      add-container-build -> add-container-build
branch 'add-container-build' set up to track 'origin/add-container-build'.
```

TODO:

- ADD FIX CERTS:

  ```console
  sudo mkdir -p /etc/docker/certs.d/172.16.99.1\:5050/
  sudo cp $GITLAB_HOME/config/ssl/172.16.99.1.crt /etc/docker/certs.d/172.16.99.1\:5050/172.16.99.1.crt
  ```

- ADD INVESTIGATION OF THE QUALITY OF THE IMAGE USING ULTIMATE TOOLS
