# Kubernetes Security Workshop

## Environment architecture

The overall architecture of this workshop project is based upon a single
Minikube cluster installation.

Everything is meant to be created on a physical machine or a virtual one
with, *at least*, 2 CPU and 4 Gigabytes of RAM. 4 CPU and 8 Gigabytes of RAM
will be ideal.

Software requirements for the main machine are essentially just the Docker
service, everything else will be covered in the various stages.

The outputs reported in the various stages were taken from a [AlmaLinux 9](https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2)
virtual machine with 4 CPUs and 8 Gigabytes of RAM.

## Workshop structure

The structure of the workshop will be based on stages:

- Stage 0: [Install Minikube](../../Common/Kubernetes-Install-Minikube.md)
- Stage 1: [Network Policies](Stage-1-Network-Policies.md).
- Stage 2: [Kyverno, Policy as Code](Stage-2-Kyverno-Policy-as-Code.md).
- Stage 3: [Cosign, Sign Container Images](Stage-3-Sign-Containers-with-Cosign.md).
- Stage 4: [Policy Reporter UI](Stage-4-Policy-Reporter-Visualization.md).

## References

There are several technologies covered in this workshop, the main ones are
listed here:

- [Kubernetes](https://kubernetes.io/), the container orchestration platform.
- [Kyverno](https://kyverno.io/), declarative Policy as Code for Kubernetes.
- [Cosign](https://github.com/sigstore/cosign), OCI containers signature tool.

## Author

Raoul Scarazzini ([raoul.scarazzini@kiratech.it](mailto:raoul.scarazzini@kiratech.it))
