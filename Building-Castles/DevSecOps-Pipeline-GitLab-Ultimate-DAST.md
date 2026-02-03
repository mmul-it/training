# Lab | Configure GitLab Ultimate DAST functionalities

In this lab you will configure a git repository to be processed by GitLab DAST
capabilities that will affect the CI process.

## Add SAST check Security Policy at Group Level

As Admin, inside our GitLab Ultimate installation we created the
`building-castles` group, and we are going to configure for every project in it
a policy that will prevent security problems from being merged.

To activate a policy that will block merge requests if SAST problems are found,
move into the group Policies page:

[https://172.16.99.1:8443/groups/building-castles/-/security/policies](https://172.16.99.1:8443/groups/building-castles/-/security/policies)

Press the `New policy` button, and under `Merge request approval policy` press
the `Select policy` button, and fill with these content the relative fields:

- Name: `Check for DAST High and Critical problems`.
- Policy scope: Apply this policy to `all projects in this group` `without
  exceptions`.
- Rules: When a `security scan` with `DAST` runs against `all protected
  branches` with `no exceptions` and finds `any` vulnerability type that matches
  all the following criteria:
  Severity is: `Critical, High`
  Status is: `New` `All vulnerability states`
- Actions: Warn users with a bot comment and select approvers. The approvers are
  required unless developers dismiss the warn mode policy. After dismissal,
  approvers become optional.
  Developers may dismiss findings to proceed or receive `1` approval from:
  `Roles` `Maintainer, Owner`.

Pressing `Configure with a merge request` will take you to the `Update security
policies` page where you can set `Assignee` to `Administrator` and then press
`Your Review` and `Approve`.

After pressing the `Merge` button a policy checker for the entire group will be
in place.

## Add faulty app to the container in myproject

On the terminal, move back to the `main` branch and ensure the repository is up
to date with the remote:

```console
$ pwd
/home/kirater/myproject

$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull
Already up to date.

$ git checkout -b add-python-api
Switched to a new branch 'add-python-api'
```

To simulate a faulty application we are going to change two of the existing
files. The first one is the Python script, which will become an application
exposing a simple API.

Create a `python/app.py` with these contents:

```python
from flask import Flask, request
import os

app = Flask(__name__)

@app.route("/")
def index():
    return "My Python fake API, call /ping to see something"

# Command Injection, the host variable could be overridden and should be
# detected by a DAST scanner
@app.route("/ping")
def ping():
    host = request.args.get("host", "127.0.0.1")
    return os.popen(f"ping -c 1 {host}").read()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Then we are going to change the `Dockerfile` so that it will execute the newly
created script:

```Dockerfile
FROM python:3.9-slim

RUN pip install flask

COPY python/app.py /app.py

EXPOSE 5000

CMD ["python", "/app.py"]
```

## Add DAST to the repository CI

Integrating DAST analysis it's a matter of three additions in `.gitlab-ci.yml`:

- A new template `Security/DAST.gitlab-ci.yml`.
- Two new variables named `DAST_WEBSITE` pointing to the application, and
  `DAST_FULL_SCAN_ENABLED` set to `true`.
- A `dast` section containing a `service` declaration, that will start the
  container and assign a `name` and an `alias` to it.

The resulting `.gitlab-ci.yml` will be something like:

```yaml
include:
- template: Security/SAST.gitlab-ci.yml
- template: Security/Container-Scanning.gitlab-ci.yml
- template: Security/DAST.gitlab-ci.yml

variables:
  SECURE_LOG_LEVEL: debug
  SCAN_KUBERNETES_MANIFESTS: 'true'
  CS_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  DAST_WEBSITE: http://app:5000
  DAST_FULL_SCAN_ENABLED: "true"

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

dast:
  stage: test
  services:
    - name: "$CS_IMAGE"
      alias: app
```

Commit and push after checking the status of the repository:

```console
$ git status
On branch add-python-api
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .gitlab-ci.yml
        modified:   Dockerfile

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        python/app.py

no changes added to commit (use "git add" and/or "git commit -a")

$ git add . && git commit -m "Add Python app and DAST check"
[add-python-api 8bd8b2a] Add Python app and DAST check
 3 files changed, 32 insertions(+), 8 deletions(-)
 create mode 100644 python/app.py

$ git push --set-upstream origin add-python-api
Enumerating objects: 10, done.
Counting objects: 100% (10/10), done.
Delta compression using up to 4 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 1.01 KiB | 1.01 MiB/s, done.
Total 6 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: 
remote: To create a merge request for add-python-api, visit:
remote:   https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/new?merge_request%5Bsource_branch%5D=add-python-api
remote: 
To ssh://172.16.99.1:2222/building-castles/myproject.git
 * [new branch]      add-python-api -> add-python-api
branch 'add-python-api' set up to track 'origin/add-python-api'.
```

It is time to follow things from the UI.

## Create the merge request from the GitLab interface

Log into the GitLab web interface and become the `devsecops` user by
clocking `Impersonate` from the user page:

[https://172.16.99.1:8443/admin/users/devsecops/](https://172.16.99.1:8443/admin/users/devsecops/)

Move into the project page:

[https://172.16.99.1:8443/building-castles/myproject](https://172.16.99.1:8443/building-castles/myproject)

You should see a message like:

> You pushed to first-test at building-castles / myproject 1 minute ago

With a `Create merge request` button. Click on it.

In the merge request summary page under `Assignees` and `Reviewers` select
`MntDevSecOps` and press `Create merge request`.

## Manage the problems

The analysis will show plenty of problems on all the three scanning method that
were implemented, the one that we're interested on is the DAST one:

- **OS Command Injection**: It is possible to execute arbitrary OS commands on 
  the target application server. OS Command Injection is a critical
  vulnerability that can lead to a full system compromise.

Which is exactly what we aimed for.

TODO:

- Fix the problem.
