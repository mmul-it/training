# Python/OpenTelemetry/Jaeger examlple

This is part of the "**Through the looking glass**" observability course which will
explore these topics:

- Prometheus Metrics
- Elastic Logs
- Jeager Trace

This lab is about Jeager Trace.

## Prepare the environment

### The Python virtual env

Create the virtualenv and install requirements via `pip':

```console
$ pip install flask opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-flask opentelemetry-instrumentation-requests opentelemetry-exporter-otlp
...
```

### The frontend application

The code of the [Frontend application](cheshire.py).

### The backend application

The code of the [Backend application]().

### The Jaeger instance

The Jaeger instance can be a single container:

```console
$ docker run --rm --name jaeger \
    -p 16686:16686 \
    -p 4318:4318 \
    jaegertracing/all-in-one:1.63.0
...
```

## Test everything

In two different terminals, launch first the backend app:

```console
$ python cheshire.py
 * Serving Flask app 'cheshire'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5001
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 813-701-761
...
```

And then the frontend:

```console
$ python alice.py
 * Serving Flask app 'alice'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 813-701-761
...
```

Finally look call the [http://localhost:5000](http://localhost:5000) url and
then check the Jaeger web interface at [http://localhost:16686](http://localhost:16686)
to query the related traces.
