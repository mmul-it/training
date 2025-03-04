# Notes

## Create Python virtual environment

The best way to make the Python scripts working is to create a Python Virtual
Environment and install in there all the packages listed inside the
`requirements.txt` file:

```console
$ python3 -m venv ~/otel
(no output)

$ source ~/otel/bin/activate
(no output)

(otel) $ pip install -r python-app/requirements.txt
...
```

Then to launch

```console
(otel) $ cd python-app
(no output)

(otel) $ ./launch.sh
 * Serving Flask app 'cheshire'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5001
Press CTRL+C to quit
 * Serving Flask app 'alice'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5000
Press CTRL+C to quit
```

Note that some tweaks inside the `python-app/variables.py` might be needed to
make everything work properly.

---

## About context propagation

How it is possible that two different scripts, both using the
`with trace_provider.start_as_current_span` function, but one using
`variables.APP_FRONTEND_NAME` and the other `variables.APP_BACKEND_NAME`
are tracked together?

They are tracked together through context propagation. Here's how it works:

- Frontend: When the frontend starts a span with its own name (e.g.,
  `variables.APP_FRONTEND_NAME`), it creates a trace context (which includes
  the trace ID, span ID, etc.). When it makes an HTTP request to the backend,
  the trace context is typically injected into the request headers (using
  standards like the W3C Trace Context).

- Backend: When the backend receives the request, it reads the trace context
  from the headers and starts a new span (using variables.APP_BACKEND_NAME).
  By using the incoming context as its parent, the backend’s span becomes part
  of the same trace. This creates a parent-child relationship between the
  frontend and backend spans.

Even though the two scripts use different span names, they are linked because
the backend continues the trace initiated by the frontend. So, even if you
later only log the trace ID, the underlying tracing system still maintains the
relationships between spans, allowing you to see the full trace of the
operation across both services.

---

## Bibliography

### Logs

The python log stuff is based upon the [Official OpenTelemetry Documentation](https://opentelemetry.io/blog/2023/logs-collection/)
and specifically on the [yoda script](https://github.com/mhausenblas/ref.otel.help/blob/main/how-to/logs-collection/yoda/main.py)
developed by [mhausenblas](https://github.com/mhausenblas).
