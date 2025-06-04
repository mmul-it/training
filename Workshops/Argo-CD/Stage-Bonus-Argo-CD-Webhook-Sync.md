# Argo CD Workshop - Webhook synchronization

This bonus stage explores how to configure a Git hook to force the
synchronization of an application.

## Force sync after the git push

Until now, new versions were picked some time after the push on the repository,
depending on the time it could have taken up to 5 minutes to have the new
deployments.

It is possible instead to deploy in Argo CD by using a webhook ignited by a
standard Git Hook.

This will work by using tokens, so a specific user must be created and enabled
to manage application sets, using a token.

To create a user edit the configmap `argocd-cm` by using
`kubectl --namespace argocd edit configmap argocd-cm` and make the content
similar to this:

```yaml
apiVersion: v1
data:
  accounts.kirater: apiKey,login
kind: ConfigMap
metadata:
...
```

Then to enable the permissions for the user, the `argocd-rbac-cm` config map
should be edited via `kubectl --namespace argocd edit configmap argocd-rbac-cm`
as follows:

```yaml
apiVersion: v1
data:
  policy.csv: |
    # Define policies for a new user with access to only one app
    p, role:webserver-access, applications,    get,  default/*-webserver, allow
    p, role:webserver-access, applications,    sync, default/*-webserver, allow
    p, role:webserver-access, applicationsets, get,  default/webserver,   allow

    # Bind the user to this role
    g, kirater, role:webserver-access
kind: ConfigMap
metadata:
...
...
```

At this point the Password (optional) and a Token for the user can be easily
generated via `argocd`:

```console
$ argocd account update-password --account kirater
*** Enter password of currently logged in user (admin):
*** Enter new password for user kirater:
*** Confirm new password for user kirater:
Password updated

$ argocd account generate-token --account kirater
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJraXJhdGVyOmFwaUtleSIsIm5iZiI6MTczMTUxNTY4MSwiaWF0IjoxNzMxNTE1NjgxLCJqdGkiOiIyMjVjODgxMi01MmI4LTQ2OTctOWViZC00YzRiY2ExMGViNzUifQ.EJrO_bvhrPBS9BqEXcCanVQd621cSvh9r7-wMlUcmaU
```

To be 100% sure the new settings are loaded it is possible to `rollout restart`
the `argocd-server` deployment (this is not usually needed):

```console
$ kubectl --namespace argocd rollout restart deployment argocd-server
deployment.apps/argocd-server restarted
```

## Enabling the Git hook

We will execute the `post-commit` hook inside the repo, so the script will be
`~/kirater-repo/.git/hooks/post-commit`, and will have this content:

```bash
#!/bin/bash

set -e

# Variables
ARGOCD_SERVER="https://172.18.0.100"
ARGOCD_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJraXJhdGVyOmFwaUtleSIsIm5iZiI6MTczMTUxODI2NSwiaWF0IjoxNzMxNTE4MjY1LCJqdGkiOiIyY2MwOTNhMC0wNzY4LTRiNDgtYTljYy04YTkzMTE1NWIzMDIifQ.ZTKHbYacGPTg-GPGQ6FxvdCMwcg6Uom-9_qsrVOW-C4"

# Case statement to set ARGOCD_APP_NAME based on the branch
GIT_BRANCH=$(git symbolic-ref --short HEAD)
case "$GIT_BRANCH" in
  "main")
    ARGOCD_APP_NAME="prod-webserver"
    ;;
  "test")
    ARGOCD_APP_NAME="test-webserver"
    ;;
  *)
    echo "Error: branch ${GIT_BRANCH} not available for deployment."
    exit 1
    ;;
esac


echo -n "Running post-commit hook... "

# Trigger ArgoCD Sync
curl -k -X POST "${ARGOCD_SERVER}/api/v1/applications/${ARGOCD_APP_NAME}/sync" \
    -H "Authorization: Bearer ${ARGOCD_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"dryRun": false}' > /dev/null 2>&1

echo "Done."
```

Once made executable:

```console
$ chmod -v +x ~/kirater-repo/.git/hooks/post-commit
mode of '/home/kirater/kirater-repo/.git/hooks/post-commit' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)
```

## Test with a commit

A new commit should activate the Arco CD sync:

```console
$ cd kirater-repo && vi application.yml
(make all the changes)

$ git add . && git commit -m "Test Argo CD webhook with post-commit hook"
Running post-commit hook... Done.
[test 0337193] Test Argo CD webhook with post-commit hook
 1 file changed, 1 insertion(+)
```

Each new synch will be tracked inside the application history:

```console
$ argocd app history argocd/test-webserver
ID  DATE                           REVISION
2   2024-11-13 17:07:19 +0000 UTC  test (751e628)
3   2024-11-13 17:49:19 +0000 UTC  test (1656d46)
4   2024-11-13 17:55:20 +0000 UTC  test (4fc9a74)
```
