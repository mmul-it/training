# Lab | Use the image generated from GitLab into a Kubernetes deployment

In this lab you will configure a Kubernetes deployment that will use the image
generated in [DevSecOps-Pipeline-GitLab-Ultimate-DAST.md](DevSecOps-Pipeline-GitLab-Ultimate-DAST.md).

## Requirements

The lab is based on a local Kubernetes installation run with Minikube, as
described in [Kubernetes-Install-Minikube.md](../Common/Kubernetes-Install-Minikube.md)
and uses the container image that was created in the previously executed lab
[DevSecOps-Pipeline-GitLab-Ultimate-DAST.md](DevSecOps-Pipeline-GitLab-Ultimate-DAST.md).

## Create a GitLab token for pull operations

Log into the GitLab web interface and become the `mntdevsecops` user by
clocking `Impersonate` from the user page:

[https://172.16.99.1:8443/admin/users/mntdevsecops/](https://172.16.99.1:8443/admin/users/mntdevsecops/)

Move into `myproject` project access tokens page:

[https://172.16.99.1:8443/building-castles/myproject/-/settings/access_tokens](https://172.16.99.1:8443/building-castles/myproject/-/settings/access_tokens)

Press `Add new token` and set these values:

- `Token name`: `Kubernetes pull`
- `Select a role`: `Developer
- `Select scopes`: `read_registry`

After pressing create copy the token. Note that if you lose it, you will need to
regenerate it.

To test the effectiveness of the token it is possible to use `docker login` as
follows:

```console
$ echo "<TOKEN>" | docker login 172.16.99.1:5050 -u mntdevsecops --password-stdin

WARNING! Your credentials are stored unencrypted in '/home/kirater/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
```

It is time to test things in Kubernetes.

## Create Kubernetes namespace and secret

We will use a dedicated namespace named `myns`:

```console
$ kubectl create namespace myns
namespace/myns created
```

Inside the namespace we will create the pull secret named
`gitlab-registry-secret` that will contain the token:

```console
$ kubectl create secret docker-registry gitlab-registry-secret \
  --namespace=myns \
  --docker-server=172.16.99.1:5050 \
  --docker-username=mntdevsecops \
  --docker-password=<TOKEN>
secret/gitlab-registry-secret created
```

This secret will be part of the deployment definition.

## Create and test Kubernetes deployment

Create the deployment file with this command:

```console
$ cat << EOF > myproject-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: myns
  name: myproject
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myproject
  template:
    metadata:
      labels:
        app: myproject
    spec:
      containers:
      - name: app
        image: 172.16.99.1:5050/building-castles/myproject:latest
        ports:
        - containerPort: 5000
      imagePullSecrets:
      - name: gitlab-registry-secret
EOF
```

To effectively deploy it, use `kubectl`:

```console
$ kubectl apply -f myproject-deployment.yml
deployment.apps/myproject created
```

After checking the effective application startup:

```console
$ kubectl -n myns get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/myproject-75cb8899d9-6zkg7   1/1     Running   0          3m3s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myproject   1/1     1            1           3m3s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/myproject-75cb8899d9   1         1         1       3m3s
```

It will be possible to map the service port using `port-forward`:

```console
$ kubectl -n myns port-forward deployments/myproject 5000:5000
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
```

And from another terminal test the application via `curl`:

```console
$ curl localhost:5000/ping
PING 127.0.0.1 (127.0.0.1): 56 data bytes
64 bytes from 127.0.0.1: seq=0 ttl=64 time=0.032 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.032/0.032/0.032 ms
```

The output shows that the application is up and running.
