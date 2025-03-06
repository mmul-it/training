from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from flask import Response

# Define your metrics objects
REQUEST_COUNTER = Counter(
    'backend_requests_total', 'Total number of processed backend requests', ["trace_id"]
)
REQUEST_LATENCY = Histogram(
    'backend_request_latency_seconds', 'Latency for processing backend requests', ["trace_id"]
)

def record_request(trace_id, duration):
    REQUEST_COUNTER.inc()
    REQUEST_LATENCY.labels(trace_id=trace_id).observe(duration)

def init(app):
    @app.route("/metrics")
    def metrics_endpoint():
        # Return the latest metrics data in the format that Prometheus expects.
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

    # You can return the metrics objects for use in your endpoints.
    return {
        "REQUEST_COUNTER": REQUEST_COUNTER,
        "REQUEST_LATENCY": REQUEST_LATENCY,
    }
