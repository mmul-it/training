# Lab | Configure and install Loki

This lab will install and configure a Loki instance inside the three Kubernetes
Kind clusters created in [Kubernetes-Install-3-Kind-Clusters.md](../../Common/Kubernetes-Install-3-Kind-Clusters.md).

## Preparation

The Helm chart used to install Loki is available at [https://grafana.github.io/helm-charts]()
and can be configured locally as follows:

```console
$ helm repo add grafana https://grafana.github.io/helm-charts
"grafana" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "grafana" chart repository
Update Complete. ⎈Happy Helming!⎈
```

A pre filled Helm values file should be locally downloaded from this repository:

- [helm/helm-loki-ctlplane.yml]()

## Loki Installation

The Helm values file contains specific configuration for the Loki instance,
specifically:

```yaml
---
loki:
  commonConfig:
    replication_factor: 1
  useTestSchema: true
  storage:
    bucketNames:
      chunks: chunks
      ruler: ruler
      admin: admin
  auth_enabled: false
  limits_config:
    # Added after Stage 2 tests failing with
    # ValueError: Unexpected Loki API response status code: 429
    # Check: https://github.com/grafana/loki/issues/11836#issuecomment-2325531717
    max_global_streams_per_user: 0
deploymentMode: SingleBinary
singleBinary:
  replicas: 1
read:
  replicas: 0
write:
  replicas: 0
backend:
  replicas: 0
```

In this configuration:

- `loki` defines a `commonConfig` limited for the test usage, disabling
  authentication and setting `max_global_streams_per_user` inside
  `limits_config` so to avoid certain Loki errors while ingesting logs during
  the tests.
- `deploymentMode` sets `singleBinary` so that this installation will be a sort
  of "all-in-one" usable for local testing.
- Other components like `read`, `write`, and `backend` elements are disabled
  since they will not be used for the tests.

One way to install the Loki chart is using the `helm upgrade --install`
command:

```console
$ kubectl config use-context kind-ctlplane
Switched to context "kind-ctlplane".

$ helm upgrade --install loki grafana/loki \
    --namespace loki \
    --create-namespace \
    --values helm-loki-ctlplane.yml
...
```

## Loki Exposition

The Loki installation creates a lot of services, but only one will be exposed to
make the overall testing work, the one named `loki`:

```console
kubectl --namespace loki expose service loki \
  --name loki-lb \
  --type LoadBalancer \
  --load-balancer-ip 172.18.0.103
service/loki-lb exposed
```

The `172.18.0.103` IP and will listen to two ports:

- `3100` (TCP): Loki API and ingestion endpoint – used for reading logs, pushing
  logs (via /loki/api/v1/push), querying, and general communication with Loki.
- `9095` (TCP): gRPC communication – used internally for communication between
  Loki components in a distributed setup (e.g., distributor, ingester, querier).

These ports will be used as reference for further OpenTelemetry labs.
