# Lab | Install the Operator SDK

In this lab you will install and nable the Operator SDK environment.

## Download and install the executable

Following the [official project website](https://sdk.operatorframework.io/), the
steps to install the `operator-sdk` tool are as simple as:

```console
$ export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
(no output)

$ export OS=$(uname | awk '{print tolower($0)}')
(no output)

$ export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.32.0
(no output)

$ curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}
...

$ sudo chmod -v +x operator-sdk_${OS}_${ARCH}
mode of 'operator-sdk_linux_amd64' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)

$ sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
renamed 'operator-sdk_linux_amd64' -> '/usr/local/bin/operator-sdk'
```

To verify that the SDK is available in the system path it is sufficient to
invoke `operator-sdk`:

```console
$ operator-sdk version
operator-sdk version: "v1.32.0", commit: "...", kubernetes version: "1.26.0", go version: "go1.19.13", GOOS: "linux", GOARCH: "amd64"
```

## Filling all the prerequisites

To automate some of the processes around the Operators installation the `make`
command will be more than useful, so it needs to be installed.

If you use a Red Hat based system:

```bash
$ sudo yum -y install make
...
```

If you use a Debian based system:

```bash
$ sudo apt -y install make
...
```

The test operator that will be implemented will use Ansible, and so there are
some [additional packages](https://sdk.operatorframework.io/docs/building-operators/ansible/installation/)
to install to fully cover the requirements, like `docker` and `python` which
should be already available on the test environment, but can be easily installed
by following the [Lab | Install Docker](https://github.com/mmul-it/training/blob/master/Common/Containers-Install-Docker.md).

Last but not least every operator relies on a container image which should be
accessible from any environment in which the operator will be installed.

In this lab the Quay public repo will be used, and to check the ability to
pull and push the `docker login` command is helpful:

```console
[kirater@training-kfs-minikube ~]$ docker login quay.io -u mmul+kiraop
Password:
WARNING! Your password will be stored unencrypted in /home/kirater/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

This will come handy once the SDK will produce a local container image to be
pushed on the Quay registry.

Info about how to create an account and enable permission on it can be found
looking at the [Quay website tutorial](https://quay.io/tutorial/).

The credentials to access the lab repo will be given by the instructor, who will
access the [Credentials for mmul+kiraop](https://quay.io/repository/mmul/kiraop?tab=settings)
and retrieve "the Username & Robot Account".
