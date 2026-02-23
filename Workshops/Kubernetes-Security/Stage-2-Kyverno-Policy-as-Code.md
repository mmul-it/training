# Kubernetes Policy as Code with Kyverno

Managing Network Policies can become quite painful when you want default
settings to be applied to the resources and your cluster.

To create policies using code one of the best solutions is [Kyverno](https://kyverno.io).

## Requisites

The fastest way to install and manage Kyverno is by using Helm:

```console
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
(no output)

$ chmod 700 get_helm.sh
(no output)

$ ./get_helm.sh
Downloading https://get.helm.sh/helm-v3.19.0-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm

$ helm repo add kyverno https://kyverno.github.io/kyverno/
"kyverno" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kyverno" chart repository
Update Complete. ⎈Happy Helming!⎈

$ helm upgrade --install kyverno kyverno/kyverno \
    --namespace kyverno --create-namespace \
    --set admissionController.hostNetwork=true \
    --version 3.7.1
NAME: kyverno
LAST DEPLOYED: Tue Oct 14 13:43:56 2025
NAMESPACE: kyverno
STATUS: deployed
REVISION: 1
NOTES:
Chart version: 3.7.1
Kyverno version: v1.17.1
...
```

## Configure the Cluster Policies

By default Kyverno installs various admission webhooks:

```console
$ kubectl get validatingwebhookconfigurations | grep kyverno
kyverno-cel-exception-validating-webhook-cfg    1          17s
kyverno-cleanup-validating-webhook-cfg          1          23s
kyverno-exception-validating-webhook-cfg        1          17s
kyverno-global-context-validating-webhook-cfg   1          17s
kyverno-policy-validating-webhook-cfg           1          17s
kyverno-resource-validating-webhook-cfg         0          17s
kyverno-ttl-validating-webhook-cfg              1          23s
```

These are used by the custom resources like `ClusterPolicy` to implement the
various behaviors.

For our test we're going to create two Cluster Policies, the first that will
assign a label named `name` to any created namespace:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-namespace-name-label
spec:
  rules:
  - name: add-namespace-name-label
    match:
      resources:
        kinds:
        - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            name: "{{request.object.metadata.name}}"
```

And the second one that implements a "deny all" by default for each newly
created namespace:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-deny
spec:
  rules:
  - name: add-default-deny
    match:
      resources:
        kinds:
        - Namespace
    generate:
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      name: default-deny-all
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      data:
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
```

After applying this policy, no Pod will be able to receive nor send network
connections, and so any modification will be covered with an override.

For this lab, we want to make the `backend` Pod in the `backend` namespace to be
reachable only by the `frontend` pod on the `frontend` namespace.

We need two Network Policies, one for each involved namespace.

The first one will define the `Ingress` rule so that the `frontend` pod will be
reachable by the `frontend` pod, and the `Egress` rule so that the `frontend`
pod in the `frontend` namespace will reach the `backend` pod in the `bacekend`
namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-egress-from-backend
  namespace: frontend
spec:
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: backend
    - podSelector:
        matchLabels:
          app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: backend
    - podSelector:
        matchLabels:
          app: backend
  podSelector:
    matchLabels:
      run: frontend
  policyTypes:
  - Ingress
  - Egress
```

The second one will define the `Ingress` rule so that the `backend` pod in the
`backend` namespace will be reachable to the `80` port from the `frontend` pod
in the `frontend` namespace, and the `Egress` rule to allow any outgoing
connection made by the `backend` pod in the `backend` namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-frontend-and-egress-to-any
  namespace: backend
spec:
  egress:
  - {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - podSelector:
        matchLabels:
          run: frontend
    ports:
    - port: 80
      protocol: TCP
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
```

## Testing everything

The script `stage-2-use-default-network-policy-on-namespaces.sh` will make it
possible to test, check and clean the described configuration, as follows:

```console
$ ./stage-2-default-network-policy-namespaces.sh
clusterpolicy.kyverno.io "add-namespace-name-label" deleted
clusterpolicy.kyverno.io "add-default-deny" deleted
namespace "backend" deleted
namespace "frontend" deleted
namespace "external" deleted
clusterpolicy.kyverno.io/add-namespace-name-label created
clusterpolicy.kyverno.io/add-default-deny created
namespace/backend created
namespace/frontend created
namespace/external created
deployment.apps/backend created
pod/backend-86565945bf-l9wlj condition met
pod/frontend created
pod/external created
Before NetworkPolicy (frontend): UNREACHABLE
Before NetworkPolicy (external): UNREACHABLE
networkpolicy.networking.k8s.io/allow-ingress-egress-from-backend created
networkpolicy.networking.k8s.io/allow-ingress-from-frontend-and-egress-to-any created
After NetworkPolicy (frontend): REACHABLE
After NetworkPolicy (external): UNREACHABLE
```

The output demonstrates that **after** adding the additional Network Policy to
allow communications between `frontend` and `backend`, just `frontend` is able
to contact `backend`.

Note that the **namespaces are automatically labeled** by the previously created
`add-namespace-name-label` Cluster Policy.

All the resources can be queried, and when you're done everything can be cleaned
with:

```console
$  ./stage-2-default-network-policy-namespaces.sh clean
Cleaning up things...
clusterpolicy.kyverno.io "add-namespace-name-label" deleted
clusterpolicy.kyverno.io "add-default-deny" deleted
namespace "backend" deleted
namespace "frontend" deleted
namespace "external" deleted
```
