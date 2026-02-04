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

# Expose the link to /ping in the default page, so that DAST can detect it
@app.route("/")
def index():
    return "<html><body><a href=\"/ping?host=127.0.0.1\">Ping</a></body></html>"

# Expose /ping API to execute command with a command injection problem to be
# detected by DAST
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
FROM python:3.14.2-alpine3.23

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

The analysis will show plenty of problems on the various scanning method that
were implemented, the one that we're interested on is the DAST one:

- **OS Command Injection**: _It is possible to execute arbitrary OS commands on 
  the target application server. OS Command Injection is a critical
  vulnerability that can lead to a full system compromise_.

Which is exactly what we aimed for.

Note that the same kind of vulnerability should be detected also by SAST, in
this form:

- **Improper neutralization of special elements used in an OS Command ('OS
  Command Injection')**: _Starting a process with a shell; seems safe, but may be
  changed in the future, consider rewriting without shell_.

Note also that it might be that the Container Scanning component will detect
some vulnerabilities on the chosen base container image, in this case 
`python:3.14.2-alpine3.23`. Problems related to the images are usually solvable
with a following version, so it might be worth checking which versions are
available in the container image page on the Docker Hub:

[https://hub.docker.com/_/python](https://hub.docker.com/_/python)

So, with a clear idea of the problem, it is easy to solve the problem, by
changing the Python application, fixing things:

```python
from flask import Flask, request
import subprocess
import ipaddress

app = Flask(__name__)

# Expose the link to /ping in the default page, so that DAST can detect it
@app.route("/")
def index():
    return "<html><body><a href=\"/ping?host=127.0.0.1\">Ping</a></body></html>"

# Expose /ping API to execute command after checking parameters
@app.route("/ping")
def ping():
    # Validate input (IP only)
    host = request.args.get("host", "127.0.0.1")
    try:
        ipaddress.ip_address(host)
    except ValueError:
        abort(400, "Invalid IP address")

    # Get the result using subprocess.run function
    result = subprocess.run(
        ["ping", "-c", "1", host],
        capture_output=True,
        text=True
    )

    # Return the result
    return result.stdout

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

The fix is related to:

- Headers: by setting the `nosniff` and omitting versions in the response.
- DAST: by checking that the `{host}` variable is an IP address.
- SAST: by using `subprocess.run` to execute the command outside a shell.

There are also two "Low" category issues detected by DAST, which could be
acceptable by our policies, but we might want to fix in the code:

- **Server header exposes version information**: _The target website returns the
  Server header and version information of this website. By exposing these
  values, attackers may attempt to identify if the target software is vulnerable
  to known vulnerabilities, or catalog known sites running particular versions
  to exploit in the future when a vulnerability is identified in the particular
  version_.

  This can be solved by changing the way the app gets exposed, by using for
  example `gunicorn` and changing the Dockerfile as follows:

  ```Dockerfile
  FROM python:3.14.2-alpine3.23

  RUN pip install flask gunicorn

  COPY python/app.py /app.py

  EXPOSE 5000

  CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--access-logfile", "-", "app:app"]
  ```

- **Missing X-Content-Type-Options: nosniff**: _The X-Content-Type-Options
  header with the value nosniff ensures that user agents do not attempt to guess
  the format of the data being received. User Agents such as browsers, commonly
  attempt to guess what the resource type being requested is, through a process
  called MIME type sniffing.
  Without this header being sent, the browser may misinterpret the data, leading
  to MIME confusion attacks. If an attacker were able to upload files that are
  accessible by using a browser, they could upload files that could be
  interpreted as HTML and execute Cross-Site Scripting (XSS) attacks_.

  This can be solved by adding `nosniff` to the header:

  ```python
  # Set proper headers for app responses
  @app.after_request
  def add_security_headers(response):
      response.headers["X-Content-Type-Options"] = "nosniff"
      return response
  ```

Even if these can be safely ignored, taking care of such problems is the right
level of paranoia needed to enforce security.

After this change, the usual workflow will be used to commit and push the
change:

```console
$ git add . && git commit -m "Fix Python app code injection"
[add-python-api 3a3eddd] Fix Python app code injection
 1 file changed, 5 insertions(+), 11 deletions(-)

$ git push
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 509 bytes | 509.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: 
remote: View merge request for add-python-api:
remote:   https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/4
remote: 
To ssh://172.16.99.1:2222/building-castles/myproject.git
   e7683f4..3a3eddd  add-python-api -> add-python-api
```

Once the new code is pushed, and the problems are all solved, after becoming
`MntDevSecOps` again, it will be possible to approve the merge.

Select the merge from:

[https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/](https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/)

And follow the same process used to activate the CI, by approving the review and
pressing `Merge`.

To include the merge inside the `main` branch, on the terminal:

```console
$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (1/1), 281 bytes | 281.00 KiB/s, done.
From ssh://172.16.99.1:2222/building-castles/myproject
   c40a0c9..931b0be  main       -> origin/main
Updating c40a0c9..931b0be
Fast-forward
 .gitlab-ci.yml |  9 +++++++++
 Dockerfile     | 13 +++++--------
 python/app.py  | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+), 8 deletions(-)
 create mode 100644 python/app.py

$ git log --oneline
931b0be (HEAD -> main, origin/main) Merge branch 'add-python-api' into 'main'
52c84d4 (origin/add-python-api, add-python-api) Fix Python app code injection
e7683f4 Add Python app and DAST check
c40a0c9 Merge branch 'add-container-build' into 'main'
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
