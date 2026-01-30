# Lab | Configure GitLab Ultimate SAST functionalities

In this lab you will configure a git repository to be processed by GitLab SAST
capabilities that will affect the CI process.

## Set Security Policy at Group Level

As Admin, inside our GitLab Ultimate installation we created the
`building-castles` group, and we are going to configure for every project in it
a policy that will prevent security problems from being merged.

To activate a policy that will block merge requests if SAST problems are found,
move into the group Policies page:

[https://172.16.99.1:8443/groups/building-castles/-/security/policies](https://172.16.99.1:8443/groups/building-castles/-/security/policies)

Press the `New policy` button, and under `Merge request approval policy` press
the `Select policy` button, and fill with these content the relative fields:

- Name: `Check for High and Critical problems`.
- Policy scope: Apply this policy to `all projects in this group` `without
  exceptions`.
- Rules: When a `security scan` with `SAST` runs against `all protected
  branches` with `no exceptions` and finds `any` vulnerability type that matches
  all the following criteria:
  Severity is: `Critical, High`
  Status is: `New` `All vulnerability states`
- Actions: Warn users with a bot comment and select approvers. The approvers are
  required unless developers dismiss the warn mode policy. After dismissal,
  approvers become optional.
  Developers may dismiss findings to proceed or receive `1` approval from:
  `Roles` `Maintainer, Owner`.

Pressing `Create new project with the new policy` will take you to the `Update
security policies` page.

After pressing the `Merge` button a policy checker for the entire group will be
in place.

## Add CI to myproject

To activate a GitLab CI and use GitLab Ultimate SAST functionalities it is
sufficient to create a file named `.gitlab-ci.yml` inside the root directory
of your project with these contents:

```console
$ cat <<EOF > .gitlab-ci.yml
include:
- template: Security/SAST.gitlab-ci.yml
variables:
  SECURE_LOG_LEVEL: debug
  SCAN_KUBERNETES_MANIFESTS: 'true'
stages:
  - test
sast:
  stage: test
EOF
```

This will activate the pre-built SAST template in GitLab
`Security/SAST.gitlab-ci.yml` and launch all the tests for the files, using a
debug log level and scanning also Kubernetes manifests (by default disabled).

Eventually the scan results will be stored in a file named
`gl-sast-report.json`.

To make everything running, it will be enough to create a branch that will
become the first merge request:

```console
$ git checkout -b activate-ci
Switched to a new branch 'activate-ci'

$ git add . && git commit -m "Activate CI"
[activate-ci 3d87982] Activate CI
 1 file changed, 9 insertions(+)
 create mode 100644 .gitlab-ci.yml

$ git push --set-upstream origin activate-ci
Warning: Permanently added '[172.16.99.1]:2222' (ED25519) to the list of known hosts.
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 413 bytes | 413.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: To create a merge request for activate-ci, visit:
remote:   http://3ce87b50f761/building-castles/myproject/-/merge_requests/new?merge_request%5Bsource_branch%5D=activate-ci
remote:
To ssh://172.16.99.1:2222/building-castles/myproject.git
 * [new branch]      activate-ci -> activate-ci
branch 'activate-ci' set up to track 'origin/activate-ci'.
```

By moving into the GitLab UI and impersonate `DevSecOps`:

[https://172.16.99.1:8443/admin/users/devsecops](https://172.16.99.1:8443/admin/users/devsecops)

A message similar to:

> You pushed to activate-ci at building-castles / myproject 3 minutes ago

with a `Create merge request` button should appear. If not, go to:

[https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/new](https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/new)

And select `activate-ci` branch on the left and then `Compare branches and
continue`.

In the merge page that appears, assign both `Assignees` and `Reviewer` to the
user `MntDevSecOps`, and then press `Create merge request`.

Stop impersonating `DevSecOps` and become `MntDevSecOps` to approve the review.

Go to:

[https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/1](https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/1)

You will see that the merge is blocked because it needs an approval.

Click on the right top button named `Your review`, in the appearing window
press `Approve` and then `Submit review`.

You will see the `Merge` button appearing, click on it to complete the merge,
stop impersonating `MngDevSecOps`.

## Add faulty code to myproject

On the terminal, move back to the `main` branch and pull the merge that was just
added:

```console
$ pwd
/home/kirater/myproject

$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git pull
Warning: Permanently added '[172.16.99.1]:2222' (ED25519) to the list of known hosts.
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (1/1), 263 bytes | 263.00 KiB/s, done.
From ssh://172.16.99.1:2222/building-castles/myproject
   58d084d..1aa90a6  main       -> origin/main
Updating 58d084d..1aa90a6
Fast-forward
 .gitlab-ci.yml | 9 +++++++++
 1 file changed, 9 insertions(+)
 create mode 100644 .gitlab-ci.yml
```

Now we will need some code inside `myproject` to check GitLab's SAST
functionalities, so we will create a faulty Kubernetes Pod manifest:

```console
$ pwd
/home/kirater/myproject

$ echo "My DevSecOps repo" > README.md
(no output)

$ mkdir -v manifests
mkdir: created directory 'manifests'

$ cat <<EOF > manifests/Pod.yml
# Intentionally insecure minimal example for Kubesec/GitLab SAST
# Kubesec commonly flags allowPrivilegeEscalation: true as critical
apiVersion: v1
kind: Pod
metadata:
  name: kubesec-demo
spec:
  containers:
  - name: kubesec-demo
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      allowPrivilegeEscalation: true
EOF
```

And a faulty Python code:

```console
$ pwd
/home/kirater/myproject

$ mkdir -v python
mkdir: created directory 'python'

$ cat <<EOF > python/script.py
# Intentionally insecure minimal example for Semgrep/GitLab SAST
# Semgrep commonly flags use of eval on untrusted input.
user_input = input("data: ")
result = eval(user_input)   # <-- insecure: Semgrep should flag this
print(result)
EOF
```

Commit and push:

```console
$ git add . && git commit -m "Introduce faulty code"
[main df3a4e3] Introduce faulty code
 3 files changed, 18 insertions(+), 93 deletions(-)
 create mode 100644 manifests/Pod.yml
 create mode 100644 python/script.py

$ git push
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 4 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (7/7), 857 bytes | 857.00 KiB/s, done.
Total 7 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: GitLab: You are not allowed to push code to protected branches on this project.
To ssh://172.16.99.1:2222/building-castles/myproject.git
 ! [remote rejected] main -> main (pre-receive hook declined)
error: failed to push some refs to 'ssh://172.16.99.1:2222/building-castles/myproject.git'
```

The reason why we're getting an error is that we're trying to push on branch
`main`, which is protected.

What we need to do is to create a branch and push it so that we will be able to
create a merge request from the GitLab interface:

```console
$ git reset --soft HEAD^1
(no output)

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md
        new file:   manifests/Pod.yml
        new file:   python/script.py

$ git log --oneline
131b023 (HEAD -> main, origin/main) Merge branch 'activate-ci' into 'main'
b85424e (origin/activate-ci, activate-ci) Activate CI
6a32ed6 (HEAD -> main, origin/main) Initial commit

$ git checkout -b first-test
Switched to a new branch 'first-test'

$ git commit -m "Introduce faulty code"
[first-test 4a12c61] Introduce faulty code
 3 files changed, 18 insertions(+), 93 deletions(-)
 create mode 100644 manifests/Pod.yml
 create mode 100644 python/script.py

$ git push --set-upstream origin first-test
Warning: Permanently added '[172.16.99.1]:2222' (ED25519) to the list of known hosts.
Enumerating objects: 10, done.
Counting objects: 100% (10/10), done.
Delta compression using up to 4 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (10/10), 3.57 KiB | 3.57 MiB/s, done.
Total 10 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: To create a merge request for first-test, visit:
remote:   http://3ce87b50f761/building-castles/myproject/-/merge_requests/new?merge_request%5Bsource_branch%5D=first-test
remote:
To ssh://172.16.99.1:2222/building-castles/myproject.git
 * [new branch]      first-test -> first-test
branch 'first-test' set up to track 'origin/first-test'.
```

## Create the merge request from the GitLab interface

Log into the GitLab web interface and become the `devsecops` user by
clocking `Impersonate` from the user page:

[https://172.16.99.1:8443/admin/users/devsecops/](https://172.16.99.1:8443/admin/users/devsecops/)

Move into the project page:

[https://172.16.99.1:8443/dashboard/projects](https://172.16.99.1:8443/dashboard/projects)

You should see a message like:

> You pushed to first-test at building-castles / myproject 1 minute ago

With a `Create merge request` button. Click on it.

In the merge request summary page under `Assignees` and `Reviewers` select
`MntDevSecOps` and press `Create merge request`.

## Manage the problems

In short, the merge request should identify all the security problems with a
message like this:

```console
Security scanning detected 16 new potential vulnerabilities
1 critical, 1 high, and 14 others
```

Viewing all pipeline findings will show the details: one is `Critical`, related
to the Kubernetes manifest, and one is `High`, related to the Python script.

Move back to the terminal.

On the manifest side, the problem is the `AllowPrivilegeEscalation` section of
the pod definition, which can be modified as follows:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubesec-demo
spec:
  containers:
  - name: kubesec-demo
    image: gcr.io/google-samples/node-hello:1.0
```

And pushed back to the repo:

```console
$ git add . && git commit -m "Fix Pod manifest"
[main fdf21ac12104] Fix Pod manifest
 1 file changed, 2 deletions(-)

$ git push
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 417 bytes | 417.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0), pack-reused 0
To ssh://172.16.99.1:2222/devsecops/myproject.git
   12e7259..d9638d7  main -> main
```

Same will be done for the Python script:

```python
import ast
user_input = input("data: ")
print(ast.literal_eval(user_input)) # safe: only evaluates Python literals, not arbitrary code
```

This modification will be pushed as well:

```console
$ git add . && git commit -m "Fix Python script"
[main a17809b] Fix Python script
 1 file changed, 2 insertions(+), 4 deletions(-)

$ git push
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 413 bytes | 413.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
To ssh://172.16.99.1:2222/devsecops/myproject.git
   611b468..a17809b  main -> main
```

After some time, the merge request will change its status, because the problems
were fixed.

This means that, after becoming `MntDevSecOps` again, it will be possible to
approve the merge.

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
Warning: Permanently added '[172.16.99.1]:2222' (ED25519) to the list of known hosts.
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (1/1), 270 bytes | 270.00 KiB/s, done.
From ssh://172.16.99.1:2222/building-castles/myproject
   1aa90a6..bde1eaf  main       -> origin/main
Updating 1aa90a6..bde1eaf
Fast-forward
 README.md         | 94 +---------------------------------------------------------------------------------------------
 manifests/Pod.yml | 10 ++++++++++
 python/script.py  |  3 +++
 3 files changed, 14 insertions(+), 93 deletions(-)
 create mode 100644 manifests/Pod.yml
 create mode 100644 python/script.py

$ git log --oneline
518849d (HEAD -> main, origin/main) Merge branch 'first-test' into 'main'
9d741e4 (origin/first-test, first-test) Fix Python script
ad61426 Fix Pod manifest
2189697 Introduce faulty code
131b023 Merge branch 'activate-ci' into 'main'
b85424e (origin/activate-ci, activate-ci) Activate CI
8e74315 Initial commit
```
