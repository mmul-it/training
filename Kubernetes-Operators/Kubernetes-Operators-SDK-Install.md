# Lab | Install the Operator SDK

## Download and install the executable

Following the [official project website](https://sdk.operatorframework.io/), the
steps to install the `operator-sdk` tool are as simple as:

```console
$ export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
$ export OS=$(uname | awk '{print tolower($0)}')
$ export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.32.0
$ curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}
$ sudo chmod +x operator-sdk_${OS}_${ARCH}
$ sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
renamed 'operator-sdk_linux_amd64' -> '/usr/local/bin/operator-sdk'
```

To verify that the SDK is available in the system path it is sufficient to
invoke `operator-sdk`:

```console
$ operator-sdk version
operator-sdk version: "v1.32.0", commit: "...", kubernetes version: "1.26.0", go version: "go1.19.13", GOOS: "linux", GOARCH: "amd64"
```
