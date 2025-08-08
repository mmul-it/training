# Test Telemetry with Python - Stage 2

This is the second stage where a Python application writes and exposes all the
telemetry data to the backends.

## Requirements

To make the app work properly at this stage the **Prometheus**, **Loki** and
**Tempo** instances needs to be installed as explained in the relative files:

- [Prometheus-Installation-And-Test.md]()
- [Tempo-Installation.md]()
- [Loki-Installation.md]()

This will make the contents of `python-app/Stage-2-Direct/variables.py` valid:

```python
APP_DEBUG=False
APP_FRONTEND_NAME='alice'
APP_FRONTEND_HOST='172.18.0.1'
APP_FRONTEND_PORT=5000
APP_BACKEND_NAME='cheshire'
APP_BACKEND_HOST='172.18.0.1'
APP_BACKEND_PORT=5001
APP_BACKEND_URL=f"http://{APP_BACKEND_HOST}:{APP_BACKEND_PORT}/process"
TRACES_ENDPOINT='172.18.0.102:6831'                       # Tempo exposed IP
LOGS_ENDPOINT='http://172.18.0.103:3100/loki/api/v1/push' # Loki exposed IP
```

There's no need to configure a `METRICS_ENDPOINT`, since metrics will be exposed
directly by each app at the `/metrics` url, and scraped by the Prometheus
ctlplane instance.

## Start stage 2 of the app

After activating the Python environment and getting into the `python-app`
directory, launching the app is just a matter of:

```console
$ ./launch.sh Stage-2-Direct
~/Git/kiratech/labs/Through-The-Looking-Glass/python-app/Stage-2-Direct ~/Git/kiratech/labs/Through-The-Looking-Glass/python-app
 * Serving Flask app 'alice'
 * Debug mode: off
 * Serving Flask app 'cheshire'
 * Debug mode: off
INFO:werkzeug:WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5000
INFO:werkzeug:Press CTRL+C to quit
INFO:werkzeug:WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5001
INFO:werkzeug:Press CTRL+C to quit
```

The frontend application will, as usual, be listening at the [http://172.18.0.1:5000]()
address.

Since the beginning, without invoking it, there will be some calls directed to
the `/metrics` url of the two apps, this happens because Prometheus is already
scraping:

```console
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:43:52] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:43:56] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:44:22] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:44:26] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:44:52] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:44:56] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:45:22] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:45:26] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:45:52] "GET /metrics HTTP/1.1" 200 -
INFO:werkzeug:172.18.0.4 - - [07/Mar/2025 11:45:56] "GET /metrics HTTP/1.1" 200 -
```

As you can see from the output the scraping interval is 30 seconds.

## Simulate traffic

A good way to start testing the app is again the `simulate-traffic.sh`:

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

All the results are part of the console's output, with groups of lines similar
to these:

```console
...
...
INFO:cheshire:Backend: Processing request from '192.168.1.50' source
INFO:werkzeug:192.168.1.50 - - [07/Mar/2025 11:47:58] "GET /process HTTP/1.1" 200 -
INFO:alice:Frontend: request at 'http://172.18.0.1:5001/process' endpoint completed
...
...
```

Apart from the log itself, showing the calls, everything else should be
available inside the Grafana's Data Sources:

- **Loki** for the logs.
- **Prometheus** for the metrics.
- **Tempo** for the traces.
