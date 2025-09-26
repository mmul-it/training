# Lab | Configure GitLab on an example git repository

In this lab you will configure a git repository to be processed by GitLab SAST
capabilities that will affect the CI process.

## Add some code into the repo

We will need some code inside `myproject` to check GitLab's SAST
functionalities, so we will create a faulty Kubernetes Pod manifest:

```console
$ pwd
/home/kirater/myproject

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

## Activate SAST in GitLab CI

To activate a GitLab CI and use GitLab's SAST functionalities it is
sufficient to create a file named `.gitlab-ci.yml` inside the root directory
of your project with these contents:

```console
$ cat <<EOF > .gitlab-ci.yml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SECURE_LOG_LEVEL: "debug"
  SCAN_KUBERNETES_MANIFESTS: "true"

stages:
  - test

sast:
  stage: test
  artifacts:
    paths:
      - gl-sast-report.json
EOF
```

This will activate the pre-built SAST template in GitLab
`Jobs/SAST.gitlab-ci.yml`
and launch all the tests for the files, using a debug log level and scanning
also Kubernetes manifests (by default disabled).

Eventually the scan results will be stored in a file named
`gl-sast-report.json`.

To make everything running, it will be enough to create a commit with all the
newly created files:

```console
$ git add . && git commit -m "Activate CI"
[main 91d522538048] Activate CI
 3 files changed, 43 insertions(+)
 create mode 100644 .gitlab-ci.yml
 create mode 100644 manifests/Pod.yml
 create mode 100644 python/script.py

$ git push
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 8 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (7/7), 1.02 KiB | 1.02 MiB/s, done.
Total 7 (delta 0), reused 0 (delta 0), pack-reused 0
To ssh://172.16.99.1:2222/devsecops/myproject.git
   aebe4fd..5506ff0  main -> main
```

## Check results

Inside the GitLab web interface, in short, under the CI/CD section of
`myproject` it will be possible to select `Pipelines` and look at the status:

![DevSecOps-Pipeline-GitLab-SAST-CI-1.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-1.png)

And after some time everything should be green:

![DevSecOps-Pipeline-GitLab-SAST-CI-2.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-2.png)

Which it seems good, apart from the fact that we introduced faulty code for
both Python script and Kubernetes manifests, and by looking at the details of
the pipelines we should see something like this:

![DevSecOps-Pipeline-GitLab-SAST-CI-Kube-Critical.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-Kube-Critical.png)

And the same applies for Python, with an `High` vulnerability found.
So, if we want to make this worthy, we need to instruct our pipeline to stop
if it finds `Critical` vulnerabilites for Kubesec and `High` vulnerabilites for
Semgrep.

## Analyze reports

Each job launched in the `test` stage produces a `gl-sast-report.json` json
artifact containing the results of each scan.
There are multiple ways to analyze this file and take actions, one is to add
a new stage named i.e. `sast-analysis` in which we will use a `jq` query to
extract the vulnerabilities based upon their severity:

```yaml
stages:
  - test
  - sast-analysis
```

We will first define two variables named `KUBESEC_SEVERITY` and
`SEMGREP_SEVERITY` that will be set to the relative severity value:

```yaml
variables:
  ...
  SEMGREP_SEVERITY: "High"
  KUBESEC_SEVERITY: "Critical"
```

Then for the analysis we want to check we will define a related and connected
job:

```yaml
sast-analysis-semgrep:
  stage: sast-analysis
  image: registry.gitlab.com/gitlab-ci-utils/curl-jq
  needs:
    - job: semgrep-sast
  script:
    - JQRESULT=$(jq -r --arg SEV "${SEMGREP_SEVERITY}" '.vulnerabilities[] | select(.severity==$SEV).description' gl-sast-report.json)
    - echo "JQRESULT -> $JQRESULT"
    - if [ "x$JQRESULT" != "x" ]; then echo -e "One or more ${SEMGREP_SEVERITY} vulnerabilities have been found:\n$JQRESULT"; exit 1; fi

sast-analysis-kubesec:
  stage: sast-analysis
  image: registry.gitlab.com/gitlab-ci-utils/curl-jq
  needs:
    - job: kubesec-sast
  script:
    - JQRESULT=$(jq -r --arg SEV "${KUBESEC_SEVERITY}" '.vulnerabilities[] | select(.severity==$SEV).description' gl-sast-report.json)
    - echo "JQRESULT -> $JQRESULT"
    - if [ "x$JQRESULT" != "x" ]; then echo -e "One or more ${KUBESEC_SEVERITY} vulnerabilities have been found:\n$JQRESULT"; exit 1; fi
```

Note that both stages are called `sast-analysis`, if there will be
vulnerabilities inside the relative json, then the pipeline will fail.

The resulting and final yaml will be something like this:

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  SECURE_LOG_LEVEL: "debug"
  SCAN_KUBERNETES_MANIFESTS: "true"
  SEMGREP_SEVERITY: "High"
  KUBESEC_SEVERITY: "Critical"

stages:
  - test
  - sast-analysis

sast:
  stage: test
  artifacts:
    paths:
      - gl-sast-report.json

sast-analysis-semgrep:
  stage: sast-analysis
  image: registry.gitlab.com/gitlab-ci-utils/curl-jq
  needs:
    - job: semgrep-sast
  script:
    - JQRESULT=$(jq -r --arg SEV "${SEMGREP_SEVERITY}" '.vulnerabilities[] | select(.severity==$SEV).description' gl-sast-report.json)
    - echo "JQRESULT -> $JQRESULT"
    - if [ "x$JQRESULT" != "x" ]; then echo -e "One or more ${SEMGREP_SEVERITY} vulnerabilities have been found:\n$JQRESULT"; exit 1; fi

sast-analysis-kubesec:
  stage: sast-analysis
  image: registry.gitlab.com/gitlab-ci-utils/curl-jq
  needs:
    - job: kubesec-sast
  script:
    - JQRESULT=$(jq -r --arg SEV "${KUBESEC_SEVERITY}" '.vulnerabilities[] | select(.severity==$SEV).description' gl-sast-report.json)
    - echo "JQRESULT -> $JQRESULT"
    - if [ "x$JQRESULT" != "x" ]; then echo -e "One or more ${KUBESEC_SEVERITY} vulnerabilities have been found:\n$JQRESULT"; exit 1; fi
```

Committing the code and pushing the changes:

```console
$ git add . && git commit -m "Add blocker for Critical vulnerabilities"
[main 43c5361cc999] Add blocker for Critical vulnerabilities
 1 file changed, 21 insertions(+)

$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 733 bytes | 733.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0
To ssh://172.16.99.1:2222/devsecops/myproject.git
   e9778bd..12e7259  main -> main
```

Should result in an additional pipeline run, with the two additional stages:

![DevSecOps-Pipeline-GitLab-SAST-CI-Pipeline-With-Check-Failed.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-Pipeline-With-Check-Failed.png)

The reason why the `sast-analysis-kubesec` ended up in a failure is the one
that was defined in the stage:

![DevSecOps-Pipeline-GitLab-SAST-CI-Pipeline-With-Check-Failed-Reason.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-Pipeline-With-Check-Failed-Reason.png)

The `Critical` vulnerability was detected.

The same applies for the Semgrep analysis, where there's a clear indication of
the `eval` function usage inside the Python script.

## Fix the problems

To fix the detected problem we need to understand it from the analysis:

![DevSecOps-Pipeline-GitLab-SAST-CI-Kube-Critical.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-Kube-Critical.png)

So the problem is the `AllowPrivilegeEscalation` section of the pod
definition, which can be modified as follows:

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

Finally, after some time, the pipeline should be all green:

![DevSecOps-Pipeline-GitLab-SAST-CI-Pipeline-With-Check-Fixed.png](images/DevSecOps-Pipeline-GitLab-SAST-CI-Pipeline-With-Check-Fixed.png)
