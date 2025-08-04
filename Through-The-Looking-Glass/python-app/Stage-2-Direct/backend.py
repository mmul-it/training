import time
import random
import traces
import logs
import metrics
import variables

from flask import Flask, request
from opentracing.propagation import Format

# Flask app
app = Flask(variables.APP_BACKEND_NAME)

# Tracing
tracer = traces.init_tracer(variables.TRACES_ENDPOINT, variables.APP_BACKEND_NAME)

# Logs
logger = logs.init(variables.LOGS_ENDPOINT, variables.APP_BACKEND_NAME)

# Metrics
metrics.init(app, variables.APP_BACKEND_NAME)

@app.route("/process")
def process():
    try:
        # Extract parent span context from incoming headers
        span_ctx = tracer.extract(Format.HTTP_HEADERS, dict(request.headers))
        # Start a child of the extracted span
        span = tracer.start_span(variables.APP_BACKEND_NAME, child_of=span_ctx)
    except Exception as e:
        # If no span was extracted, then create a new one (the backend was called directly)
        span = tracer.start_span(variables.APP_BACKEND_NAME)

    # Within the span (new or child of doesn't count)
    with span:
        # Extract trace_id
        trace_id = format(span.trace_id, "x")
        # Get the client IP remote address
        client_ip = request.remote_addr

        # Simulate workload and record metrics based on trace_id
        start_time = time.time()
        time.sleep(random.uniform(0.1, 2.0))
        duration = time.time() - start_time
        metrics.record_request(duration, trace_id)

        # Record logs
        message = f"Backend: Processing request from '{client_ip}'"
        logger.info(message, extra={"tags": {"trace_id": trace_id}})

        # Return with a message
        return "Processed data in Backend!"

if __name__ == "__main__":
    # Start the flask based web application
    app.run(debug=variables.APP_DEBUG, host=variables.APP_BACKEND_HOST, port=variables.APP_BACKEND_PORT)
