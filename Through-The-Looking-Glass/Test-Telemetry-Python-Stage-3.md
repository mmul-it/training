# Test Telemetry with Python - Stage 3

This is the third and last stage where a Python application writes and exposes
all the telemetry data to the OpenTelemetry Collector that will collect
everything in a standard way and distribute to the specific backends.

## Requirements

This stage requires **Prometheus**, **Loki**, **Tempo**, and **OpenTelemetry
Collector** to be properly installed and configured inside the Kubernetes
control plane, following the instructions inside the various files:

- [Prometheus-Installation-And-Test.md]()
- [Tempo-Installation.md]()
- [Loki-Installation.md]()
- [OpenTelemetry-Collector-Installation.md]()

This will make the contents of `python-app/Stage-3-Direct/variables.py` valid:

```python
APP_DEBUG=False
APP_FRONTEND_NAME='alice'
APP_FRONTEND_HOST='172.18.0.1'
APP_FRONTEND_PORT=5000
APP_BACKEND_NAME='cheshire'
APP_BACKEND_HOST='172.18.0.1'
APP_BACKEND_PORT=5001
APP_BACKEND_URL=f"http://{APP_BACKEND_HOST}:{APP_BACKEND_PORT}/process"
TRACES_ENDPOINT='172.18.0.104:4317'         # otel-collector
LOGS_ENDPOINT='http://172.18.0.104:4317'    # otel-collector
METRICS_ENDPOINT='172.18.0.104:4317'        # otel-collector
```

The endpoint, as well as the protocol, is the same for all the services:
**OTLP/gRPC**.

## Start stage 3 of the app

Nothing changes from the previous stages. After activating the Python
environment and getting into the `python-app` directory, launching the app is
just a matter of:

```console
$ ./launch.sh Stage-3-OTel
~/Git/kiratech/labs/Through-The-Looking-Glass/python-app/Stage-3-OTel ~/Git/kiratech/labs/Through-The-Looking-Glass/python-app
 * Serving Flask app 'alice'
 * Debug mode: on
 * Serving Flask app 'cheshire'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5000
Press CTRL+C to quit
 * Restarting with stat
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5001
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 197-316-231
 * Debugger is active!
 * Debugger PIN: 197-316-231
```

The frontend application will, as usual, be listening at the [http://172.18.0.1:5000]()
address.

Note that since the scrape configuration for Prometheus on the stage 2
applications is still present, there will still be some `GET` actions, but this
time the result for them will be a 404, not found, because we're not exposing
anymore metrics this way (we're pushing them to the `otel-collector`):

```console
172.18.0.4 - - [07/Mar/2025 12:03:52] "GET /metrics HTTP/1.1" 404 -
172.18.0.4 - - [07/Mar/2025 12:03:56] "GET /metrics HTTP/1.1" 404 -
172.18.0.4 - - [07/Mar/2025 12:04:22] "GET /metrics HTTP/1.1" 404 -
172.18.0.4 - - [07/Mar/2025 12:04:26] "GET /metrics HTTP/1.1" 404 -
```

There is nothing to worry about these.

## Simulate traffic

To start testing the app let's use again the `simulate-traffic.sh`:

```console
$ ./simulate-traffic.sh
Starting traffic simulation...
Doing 47 parallel requests...
Doing 11 parallel requests...
Doing 40 parallel requests...
Doing 6 parallel requests...
Doing 48 parallel requests...
Doing 19 parallel requests...
Doing 9 parallel requests...
Doing 18 parallel requests...
...
```

Remember that the script will continue until the `Ctrl+C` key combination will
be pressed.

## Look at the results

This time the output logs will be limited to:

```console
...
...
192.168.1.50 - - [07/Mar/2025 12:07:14] "GET /process HTTP/1.1" 200 -
192.168.1.50 - - [07/Mar/2025 12:07:14] "GET / HTTP/1.1" 200 -
...
...
```

This happens because all the logs are sent to the collector, and just the GET
are stored to the standard output.

Agai, to check everything on the Grafana side look at the Data Sources:

- **Loki** for the logs.
- **Prometheus** for the metrics.
- **Tempo** for the traces.
