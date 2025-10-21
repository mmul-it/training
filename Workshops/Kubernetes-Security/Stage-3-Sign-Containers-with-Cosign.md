# Sign Containers with Cosign

One of the best way to secure your own software supply chain is to _know_
exactly what is running on your systems. This means finding a way to identify
the validity of the software.

Since software in the cloud-native era means containers, then identifying
software means verifying the validity of the containers.

In this lab we will implement a way to sign and verify signatures of containers
using the `cosign` tool, and then we will implement a Cluster Policy to create
an admission control based upon containers signature with Kyverno.

## Requisites

The `cosign` binary is available on GitHub, and can be easily installed as follows:

```console
$ export COSIGN_VERSION=v3.0.2
(no output)

$ sudo curl -sSfL https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64 \
    -o /usr/local/bin/cosign

$ sudo chmod -v +x /usr/local/bin/cosign
mode of '/usr/local/bin/cosign' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)

$ cosign version
  ______   ______        _______. __    _______ .__   __.
 /      | /  __  \      /       ||  |  /  _____||  \ |  |
|  ,----'|  |  |  |    |   (----`|  | |  |  __  |   \|  |
|  |     |  |  |  |     \   \    |  | |  | |_ | |  . `  |
|  `----.|  `--'  | .----)   |   |  | |  |__| | |  |\   |
 \______| \______/  |_______/    |__|  \______| |__| \__|
cosign: A tool for Container Signing, Verification and Storage in an OCI registry.

GitVersion:    v3.0.2
GitCommit:     84449696f0658a5ef5f2abba87fdd3f8b17ca1be
GitTreeState:  clean
BuildDate:     2025-10-10T18:17:56Z
GoVersion:     go1.25.1
Compiler:      gc
Platform:      linux/amd64
```

We will use a key pair to sign and then verify the signatures. The key pair can
be created using `cosign` as follows:

```console
$ cosign generate-key-pair
Enter password for private key:
Enter password for private key again:
Private key written to cosign.key
Public key written to cosign.pub

$ ls -1 cosign.*
cosign.key
cosign.pub
```

## Build the container

In this example we will create a local container build to be pushed on the
GitHub registry, [ghcr.io](ghcr.io). This means that we will need to create a
token from the web interface and then login using `docker`:

```console
$ docker login ghcr.io
Username: <YOUR GITHUB USERNAME>
Password:

WARNING! Your credentials are stored unencrypted in '/home/kirater/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
```

We will work in a working directory named `build`:

```console
$ mkdir -v build
mkdir: created directory 'build'
```

That will contain the `build/Dockerfile` file:

```Dockerfile
FROM busybox:stable

LABEL org.opencontainers.image.description="Kiratech Training Labs Sample Containter"

ENV NCAT_MESSAGE="Container test"
ENV NCAT_HEADER="HTTP/1.1 200 OK"
ENV NCAT_PORT="8888"

RUN addgroup -S nonroot && \
    adduser -S nonroot -G nonroot

COPY start-ws.sh /usr/local/bin/start-ws.sh

USER nonroot

CMD ["/usr/local/bin/start-ws.sh"]
```

And the `build/start-ws.sh` file:

```bash
#!/bin/sh

/bin/nc -l -k -p ${NCAT_PORT} -e /bin/echo -e "${NCAT_HEADER}\n\n${NCAT_MESSAGE}"
```

That will be executable:

```console
$ chmod -v +x build/start-ws.sh
mode of 'build/start-ws.sh' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)
```

With all this in place, the build can be started:

```console
$ docker build -f build/Dockerfile -t ncat-http-msg-port:1.0 build/
[+] Building 1.3s (8/8) FINISHED                                                                                        docker:default
 => [internal] load build definition from Dockerfile                                                                              0.0s
 => => transferring dockerfile: 454B                                                                                              0.0s
 => [internal] load metadata for docker.io/library/busybox:stable                                                                 0.9s
 => [internal] load .dockerignore                                                                                                 0.0s
 => => transferring context: 2B                                                                                                   0.0s
 => [1/3] FROM docker.io/library/busybox:stable@sha256:1fcf5df59121b92d61e066df1788e8df0cc35623f5d62d9679a41e163b6a0cdb           0.1s
 => => resolve docker.io/library/busybox:stable@sha256:1fcf5df59121b92d61e066df1788e8df0cc35623f5d62d9679a41e163b6a0cdb           0.1s
 => [internal] load build context                                                                                                 0.1s
 => => transferring context: 91B                                                                                                  0.0s
 => CACHED [2/3] RUN addgroup -S nonroot &&     adduser -S nonroot -G nonroot                                                     0.0s
 => CACHED [3/3] COPY start-ws.sh /usr/local/bin/start-ws.sh                                                                      0.0s
 => exporting to image                                                                                                            0.1s
 => => exporting layers                                                                                                           0.0s
 => => writing image sha256:9fc1cf6f30e7a1c4b80a2eeba794eba3bc2279e292dd0e007d9b7efbba8a09f0                                      0.0s
 => => naming to docker.io/library/ncat-http-msg-port:1.0
```

To check if the built container behaves correctly, just launch it:

```console
$ docker run --rm --name ncat-test --detach --publish 8888:8888 ncat-http-msg-port:1.0
3b26b79bdbdb9be63542cc6f446c21a2634b9829fbae7a3213f66a3254104231

$ curl localhost:8888
Container test

$ docker stop ncat-test
ncat-test
```

Since the verification is successful, it is time to tag and push the image on
the remote registry as `ghcr.io/kiratech/ncat-http-msg-port:1.0`:

```console
$ docker tag ncat-http-msg-port:1.0 ghcr.io/kiratech/ncat-http-msg-port:1.0
(no output)

$ docker push ghcr.io/kiratech/ncat-http-msg-port:1.0
The push refers to repository [ghcr.io/kiratech/ncat-http-msg-port]
9f430253f8ea: Pushed
6cd0376aea2a: Pushed
b4cb8796a924: Pushed
1.0: digest: sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d size: 942
```

**NOTE**: it might be needed to "Change visibility" under [GitHub Package Settings](https://github.com/orgs/kiratech/packages/container/ncat-http-msg-port/settings)
from `Private` to `Public`, so that the published container will be pulled
without the need of authenticating.

## Sign the pushed container image

To sign the container, first the digest of the pushed image is needed:

```console
$ docker buildx imagetools inspect ghcr.io/kiratech/ncat-http-msg-port:1.0
Name:      ghcr.io/kiratech/ncat-http-msg-port:1.0
MediaType: application/vnd.docker.distribution.manifest.v2+json
Digest:    sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d
```

This will be used as a reference for the signature:

```console
$ cosign sign --key cosign.key ghcr.io/kiratech/ncat-http-msg-port@sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d
Enter password for private key:
```

No output means that everything was successful. The effective signature can be
verified by using `cosign verify`, and note that the result is the same while
using the `1.0` tag or the entire container image digest:

```console
$ cosign verify --key cosign.pub ghcr.io/kiratech/ncat-http-msg-port:1.0

Verification for ghcr.io/kiratech/ncat-http-msg-port:1.0 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"ghcr.io/kiratech/ncat-http-msg-port:1.0"},"image":{"docker-manifest-digest":"sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":null}]

$ cosign verify --key cosign.pub ghcr.io/kiratech/ncat-http-msg-port@sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d

Verification for ghcr.io/kiratech/ncat-http-msg-port@sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"ghcr.io/kiratech/ncat-http-msg-port@sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d"},"image":{"docker-manifest-digest":"sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":null}]
```

## Create the Kyverno ClusterPolicy

To implement a protection mechanism that will prevent non signed container
images inside the cluster, a Cluster Policy can be defined in a file named
`verify-signed-images.yaml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  webhookConfiguration:
    failurePolicy: Fail
    timeoutSeconds: 30
  background: false
  rules:
    - name: check-image-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
              namespaces:
                - default
      verifyImages:
        - imageReferences:
            - "*"
          failureAction: Enforce
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEttnyHZwdv2FXGGYBD7StTZ68VlmT
                      cmcV1SV2s8NRa8HOBzxDB2+VKKN/c74W3rK2V80pAUNGKBHjKJ4iC++Yeg==
                      -----END PUBLIC KEY-----
```

This will fail (check `webhookConfiguration`) to launch Pods that will not have
a signature based on the generated public key (check `verifyImages` section).

## Test everything

Testing the behavior of the cluster policy is a matter of just trying to run
Pods with signed and non signed containers:

```console
$ kubectl run goodpod --image=ghcr.io/kiratech/ncat-http-msg-port:1.0
pod/goodpod created

$ kubectl get pod goodpod -o jsonpath='{.metadata.annotations.kyverno\.io\/verify-images}'; echo
{"ghcr.io/kiratech/ncat-http-msg-port@sha256:dc52cb7aa471b909f7cdb70ee281ee9ee2ad0ce821dcb964785e5259a7bd4a5d":"pass"}

$ kubectl run notgoodpod --image=nginx
Error from server: admission webhook "mutate.kyverno.svc-fail" denied the request:

resource Pod/default/notgoodpod was blocked due to the following policies

require-signed-images:
  check-image-signature: 'failed to verify image docker.io/nginx:latest: .attestors[0].entries[0].keys:
    no signatures found'
```
