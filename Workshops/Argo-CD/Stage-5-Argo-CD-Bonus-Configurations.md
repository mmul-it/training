# Argo CD Workshop - Stage 5

Now that the environment is 100% operative let's check some additional Argo CD
features.

## Force sync after the git push

Until now, new versions were picked some time after the push on the repository,
depending on the time it could have taken up to 5 minutes to have the new
deployments.

It is possible instead to deploy in Argo CD by using a webhook ignited by a
standard Git Hook.

This will work by using tokens, so a specific user must be created and enabled
to manage application sets, using a token.

To create a user edit the configmap `argocd-cm` by using
`kubectl edit configmap argocd-cm -n argocd` and make the content similar to
this:

```yaml
apiVersion: v1
data:
  accounts.kirater: apiKey,login
kind: ConfigMap
metadata:
...
```

Then to enable the permissions for the user, the `argocd-rbac-cm` config map
should be edited via `kubectl edit configmap argocd-rbac-cm -n argocd` as
follows:

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

At this point the Password and a Token for the user can be easily generated via
`argocd`:

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
the `argocd-server` deployment:

```console
$ kubectl rollout restart deployment argocd-server -n argocd
deployment.apps/argocd-server restarted
```

8SGAzmgoWa8BfPDP

# Enabling the Git hook

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

A new commit should activate the Arco CD sync:

```console
$ cd kirater-repo && vi application.yml
(make all the changes)

$ git add . && git commit -m "Test Argo CD webhook with post-commit hook"
Running post-commit hook... Done.
[test 0337193] Test Argo CD webhook with post-commit hook
 1 file changed, 1 insertion(+)
```

## Monitoring

Helm installation:

```console
$ curl -o helm.tar.gz https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 15.4M  100 15.4M    0     0  12.7M      0  0:00:01  0:00:01 --:--:-- 12.7M

$ tar -xvf helm.tar.gz
linux-amd64/
linux-amd64/helm
linux-amd64/LICENSE
linux-amd64/README.md

$ sudo mv -v linux-amd64/helm /usr/local/bin/helm
renamed 'linux-amd64/helm' -> '/usr/local/bin/helm'

$ helm version
version.BuildInfo{Version:"v3.13.2", GitCommit:"2a2fb3b98829f1e0be6fb18af2f6599e0f4e8243", GitTreeState:"clean", GoVersion:"go1.20.10"}
```

Prometheus installation:

```console
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

$ helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
NAME: prometheus
LAST DEPLOYED: Thu Nov 14 15:31:27 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

Grafana configuration:

```console
$ kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator

$ kubectl -n monitoring expose deployment prometheus-grafana --type=LoadBalancer --name=prometheus-grafana-lb
service/prometheus-grafana-lb exposed

$ kubectl -n monitoring get services prometheus-grafana-lb
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                        AGE
prometheus-grafana-lb   LoadBalancer   10.96.60.180   172.18.0.101   3000:32167/TCP,9094:30744/TCP,9094:30744/UDP   26s
```

Prometheus `ServiceMonitor` enablement, by creating the confs:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-metrics
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-server-metrics
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-server-metrics
  endpoints:
  - port: metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-repo-server-metrics
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-repo-server
  endpoints:
  - port: metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-applicationset-controller-metrics
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-applicationset-controller
  endpoints:
  - port: metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-dex-server
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-dex-server
  endpoints:
    - port: metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-redis-haproxy-metrics
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-redis-ha-haproxy
  endpoints:
  - port: http-exporter-port
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: argocd
  name: argocd-notifications-controller
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-notifications-controller-metrics
  endpoints:
    - port: metrics
```

And applying them:

```console
```

Last, but not least to import an ArgoCD Grafana Dashboard, pick
[https://github.com/argoproj/argo-cd/blob/master/examples/dashboard.json](https://github.com/argoproj/argo-cd/blob/master/examples/dashboard.json)
amd import the dashboard by opening Grafana at [http://172.18.0.101:3000](http://172.18.0.101:3000).

Then go to `Dashboards` > `New` > `Import` and paste the JSON file into the text
area and press `Load`.

After importing, you should see metrics and visualizations for ArgoCD, including
sync status, application health, and operational metrics, on your new dashboard.
