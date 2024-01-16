# Demonstration | Podman: use different networking to expose ports

The ncat-message-to-http-port container image supports three parameters, with
these defaults:

```Dockerfile
NCAT_MESSAGE "Container test"
NCAT_HEADER "HTTP/1.1 200 OK"
NCAT_PORT "8888"
```

By default it opens `$NCAT_PORT` with a `$NCAT_HEADER` that displays the
`$NCAT_MESSAGE`.
Different type of `--network` can lead to similar results. Consider the usag of
`--network host` and the environmental variable `NCAT_PORT` set to `9999`:

```console
$ podman run -d --name ncat-test --rm -e NCAT_PORT=9999 --network host www.mmul.it:5000/ncat-message-to-http-port
43971ee8ff7543f8874128e9fe5c269d350b2b7f688d30f27ddafff3870166c3
```

This will lead to:

```console
$ curl localhost:9999
Container test
```

```console
$ podman stop ncat-test
43971ee8ff7543f8874128e9fe5c269d350b2b7f688d30f27ddafff3870166c3
```

Now, we can obtain the same result by using the default network setting and
publishing the port as follows:

```console
$ podman run -d --name ncat-test --rm -e NCAT_PORT=9999 -p 9999:9999 www.mmul.it:5000/ncat-message-to-http-port
686d1f17a516ede814083e60b3fb268116bb9af7c77f758af7cf9e0f5fddd3d7
```

```console
$ curl localhost:9999
Container test
```

```console
$ podman stop ncat-test
686d1f17a516ede814083e60b3fb268116bb9af7c77f758af7cf9e0f5fddd3d7
```

Note that the port we're exposing in an unprivileged one, so it can be used in
our Podman rootless environment.
