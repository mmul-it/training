from prometheus_client import Counter, Histogram, Gauge, REGISTRY
from prometheus_client.openmetrics.exposition import generate_latest,CONTENT_TYPE_LATEST
from flask import Response

# METRICS

# These variables will hold our Prometheus metric objects
# We define them as global so they can be accessed from anywhere in the script
REQUEST_COUNTER = None
REQUEST_LATENCY = None
REQUEST_DURATION = None

def init(app, app_name):
    # We need to modify the global variables inside this function
    global REQUEST_COUNTER, REQUEST_LATENCY, REQUEST_DURATION

    # Create metrics objects
    REQUEST_COUNTER = Counter(
        f"{app_name}_requests_total",
        'Total number of processed backend requests (counter)'
    )
    REQUEST_LATENCY = Histogram(
        f"{app_name}_request_latency_seconds",
        'Latency for processing backend requests (histogram)'
    )
    REQUEST_DURATION = Gauge(
        f"{app_name}_request_duration_seconds",
        'Duration for processing single request (gauge)'
    )

    # Define a route in the Flask app to expose metrics
    @app.route("/metrics")
    def metrics_endpoint():
        # Return the latest metrics data in the format that Prometheus expects.
        return Response(generate_latest(REGISTRY), mimetype=CONTENT_TYPE_LATEST)

def record_request(duration, trace_id):
    # Increment the counter by 1 to mark that a request was processed
    REQUEST_COUNTER.inc(exemplar={"trace_id": trace_id})
    # Record how long the request took in the histogram, labeled by trace_id
    REQUEST_LATENCY.observe(duration, exemplar={"trace_id": trace_id})
    # Gauge does not support exemplars
    REQUEST_DURATION.set(duration)
