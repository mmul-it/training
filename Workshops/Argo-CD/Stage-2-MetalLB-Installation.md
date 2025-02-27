# Argo CD Workshop - Stage 2

A number of services will be exposed inside the Kind default subnet,
specifically:

- The Argo CD interface on the `kind-ctlplane` cluster, with the `172.18.0.100` IP.
- The deployment on the `kind-test` cluster, with the `172.18.0.120` IP.
- The deployment on the `kind-prod` cluster, with the `172.18.0.140` IP.

Each cluster will expose an IP for the services using
[MetalLB](https://metallb.universe.tf/), and instructions on how to install
MetalLB are explained in
[Kubernetes-Configure-3-Kind-Clusters-MetalLB.md](../../Common/Kubernetes-Configure-3-Kind-Clusters-MetalLB.md).

Once the MetalLB configuration is complete, it will be possible to proceed with
[Stage 3](Stage-3-Argo-CD-Installation.md).
