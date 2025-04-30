# Test Telemetry with Python - Stage 2

This is the second stage where a Python application writes and exposes all the
telemetry data to the backends.

## Requirements

To make the app work properly at this stage the Prometheus instance configured
inside the Kubernetes control plane should be configured with the ability to
scrape from the Frontend and Backend `/metrics` locations, as declared in the
[helm-prometheus-ctlplane.yml](helm-prometheus-ctlplane.yml) configuration file:

```yaml
grafana:
  enabled: false

alertmanager:
  enabled: false

prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
      # This is used to scrape from the python exposed metrics
      - job_name: 'python-app'
        static_configs:
          - targets:
            - '172.18.0.1:5000'
            - '172.18.0.1:5001'
...
```

To be sure this is applied inside the existing Prometheus instance it is
sufficient to upgrade via `helm` the installation:

```console
$ helm upgrade prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --values helm-prometheus-ctlplane.yml
NAME: prometheus
LAST DEPLOYED: Fri Mar  7 11:42:58 2025
NAMESPACE: monitoring
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

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

The frontend application will, as usual, be listening at the [http://172.18.0.1:5000](http://172.18.0.1:5000)
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
