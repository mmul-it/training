from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from flask import Response

# METRICS

# These variables will hold our Prometheus metric objects
# We define them as global so they can be accessed from anywhere in the script
REQUEST_COUNTER = None
REQUEST_LATENCY = None

def init(app, app_name):
    # We need to modify the global variables inside this function
    global REQUEST_COUNTER, REQUEST_LATENCY

    # Create a Prometheus counter metric
    # This keeps track of how many backend requests have been processed in total
    # The metric name will be "<app_name>_requests_total"
    REQUEST_COUNTER = Counter(
        f"{app_name}_requests_total", 'Total number of processed backend requests'
    )

    # Create a Prometheus histogram metric
    # This tracks how long each backend request takes (latency), in seconds
    # The "trace_id" is used as a label to allow filtering per request trace
    REQUEST_LATENCY = Histogram(
        f"{app_name}_request_latency_seconds", 'Latency for processing backend requests', ["trace_id"]
    )

    # Define a route in the Flask app to expose metrics
    @app.route("/metrics")
    def metrics_endpoint():
        # Return the latest metrics data in the format that Prometheus expects.
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

def record_request(duration, trace_id):
    # Increment the counter by 1 to mark that a request was processed
    REQUEST_COUNTER.inc()

    # Record how long the request took in the histogram, labeled by trace_id
    REQUEST_LATENCY.labels(trace_id=trace_id).observe(duration)
