from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from flask import Response

REQUEST_COUNTER = None
REQUEST_LATENCY = None

def init(app, app_name):
    global REQUEST_COUNTER, REQUEST_LATENCY

    # Define your metrics objects
    REQUEST_COUNTER = Counter(
        f"{app_name}_requests_total", 'Total number of processed backend requests'
    )
    REQUEST_LATENCY = Histogram(
        f"{app_name}_request_latency_seconds", 'Latency for processing backend requests', ["trace_id"]
    )

    @app.route("/metrics")
    def metrics_endpoint():
        # Return the latest metrics data in the format that Prometheus expects.
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

def record_request(duration, trace_id):
    REQUEST_COUNTER.inc()
    REQUEST_LATENCY.labels(trace_id=trace_id).observe(duration)
