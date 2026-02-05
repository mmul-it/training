# Lab | GitLab Ultimate container image management

In this lab you will understand how GitLab Ultimate manages, scan and stores
container images coming from the pipelines.

## Where does GitLab stores container images

GitLab Ultimate by default comes with a Container Registry, a secure and private
registry for container images. It’s built on open source software and completely
integrated within GitLab.

One way to understand where the Container Registry lives is by looking at the
content of these environmental variables that are passed in every pipeline run:

| Variable               | Meaning                             |
|------------------------|-------------------------------------|
| `CI_REGISTRY`          | Registry address                    |
| `CI_REGISTRY_IMAGE`    | Complete path of the produced image |
| `CI_REGISTRY_USER`     | Registry user                       |
| `CI_REGISTRY_PASSWORD` | Temporary pipeline registry token   |
| `CI_COMMIT_SHA`        | Commit SHA                          |

## Container image build

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

## Add Container image check Policy at Group Level

Impersonate `AdmDevSecOps` user and move to the `building-castles` group, where
we are going to configure an additional Policy, for every project in it, so that
any produced image will be scanned by the GitLab Ultimate tools.

Move into the group Policies page:

[https://172.16.99.1:8443/groups/building-castles/-/security/policies](https://172.16.99.1:8443/groups/building-castles/-/security/policies)

Press the `New policy` button, and under `Merge request approval policy` press
the `Select policy` button, and fill with these content the relative fields:

- Name: `Check for Container images High and Critical problems`.
- Policy scope: Apply this policy to `all projects in this group` `without
  exceptions`.
- Rules: When a `security scan` with `Container Scanning` runs against `all
  protected branches` with `no exceptions` and finds `any` vulnerability type
  that matches all the following criteria:
  Severity is: `Critical, High`
  Status is: `New` `All vulnerability states`
- Actions: Warn users with a bot comment and select approvers. The approvers are
  required unless developers dismiss the warn mode policy. After dismissal,
  approvers become optional.
  Developers may dismiss findings to proceed or receive `1` approval from:
  `Roles` `Maintainer, Owner`.

Pressing `Create new project with the new policy` will take you to the `Update
security policies` page.

You will need to approve this merge request, and this can be done by pressing on
`Assign reviewers` and adding `AdmDevSecOps` itself. Clicking `Your review` will
make you able to select `Approve` and then press `Submit review`.

After pressing the `Merge` button a policy checker for the entire group will be
in place.

## Add Container image check to CI

To include the Container image check coming from GitLab Ultimate, the `template`
named `Security/Container-Scanning.gitlab-ci.yml` must be added inside the
`.gitlab-ci.yml` file.

To activate the scan, a `container_scanning` stage is the only thing needed,
with no details. The full new `.gitlab-ci.yml` file will be something like this:

```yaml
include:
- template: Security/SAST.gitlab-ci.yml
- template: Security/Container-Scanning.gitlab-ci.yml

variables:
  SECURE_LOG_LEVEL: debug
  SCAN_KUBERNETES_MANIFESTS: 'true'
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

container_scanning:
  stage: test
```

The modification should be committed and pushed as usual:

```console
$ git add . && git commit -m "Add container test"
[add-container-build 963b45c] Add container test
 1 file changed, 3 insertions(+), 2 deletions(-)

$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 362 bytes | 362.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: To create a merge request for add-container-build, visit:
remote:   https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/new?merge_request%5Bsource_branch%5D=add-container-build
remote:
To ssh://172.16.99.1:2222/building-castles/myproject.git
   e90df89..963b45c  add-container-build -> add-container-build
```

Note that we're still inside the `add-container-build` branch.

Looking at the pipeline produced by the push a new (green) `container_scanning`
action in the `test` stage will appear.

Stop impersonating `AdmDevSecOps` and become `DevSecOps`. On the top of the page
a message saying `You pushed to add-container-build at building-castles
 / myproject 4 minutes ago` with a `Create merge request` button.

Press the button, select `MntDevSecOps` as both `Assignees` and `Reviewers`, and
press `Create merge request`.

After a while, inside the pipeline findings a message saying `Security scanning
detected 1 new potential vulnerability`, with `1 critical` problem should
appear.

Looking at the details of the messages the `Critical` (expected) problem, which
is related to the specific CVE [CVE-2021-36159](https://nvd.nist.gov/vuln/detail/CVE-2021-36159),
and a (quick) investigation tells us that we're using an end-of-life Alpine
release.

## Manage the problems

To make the Container scanning pass, it will be sufficient to use the `3.23`
version of Alpine, change it inside the `Dockerfile`:

```Dockerfile
FROM alpine:3.23
```

And then commit and push the change:

```console
$ git add . && git commit -m "Fix Alpine version"
[add-container-build 183f301] Fix Alpine version
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 304 bytes | 304.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: View merge request for add-container-build:
remote:   https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/3
remote:
To ssh://172.16.99.1:2222/building-castles/myproject.git
   6397d85..183f301  add-container-build -> add-container-build
```

After some time, the merge request will change its status, because the problems
were fixed.

This means that, after becoming `MntDevSecOps` again, it will be possible to
approve the merge.

Select the merge from:

[https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/](https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/)

And follow the same process used in the previous merges, approving the review
and pressing `Merge`.

To include the merge inside the `main` branch, on the terminal:

```console
$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (1/1), 268 bytes | 268.00 KiB/s, done.
From ssh://172.16.99.1:2222/building-castles/myproject
   518849d..c40a0c9  main       -> origin/main
Updating 518849d..c40a0c9
Fast-forward
 .gitlab-ci.yml | 18 +++++++++++++++++-
 Dockerfile     | 12 ++++++++++++
 2 files changed, 29 insertions(+), 1 deletion(-)
 create mode 100644 Dockerfile

$ git log --oneline
c40a0c9 (HEAD -> main, origin/main) Merge branch 'add-container-build' into 'main'
183f301 (origin/add-container-build, add-container-build) Fix Alpine version
6397d85 Add container test
e90df89 Add container build and push
518849d Merge branch 'first-test' into 'main'
9d741e4 (origin/first-test, first-test) Fix Python script
ad61426 Fix Pod manifest
2189697 Introduce faulty code
131b023 Merge branch 'activate-ci' into 'main'
b85424e (origin/activate-ci, activate-ci) Activate CI
8e74315 Initial commit
```
