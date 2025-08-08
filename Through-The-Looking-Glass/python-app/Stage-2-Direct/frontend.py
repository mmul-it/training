import time
import random
import requests

import traces
import logs
import metrics
import variables

from flask import Flask, request
from opentracing.propagation import Format

# Flask app
app = Flask(variables.APP_FRONTEND_NAME)

# Tracing
tracer = traces.init_tracer(variables.TRACES_ENDPOINT, variables.APP_FRONTEND_NAME)

# Logs
logger = logs.init(variables.LOGS_ENDPOINT, variables.APP_FRONTEND_NAME)

# Metrics
metrics.init(app, variables.APP_FRONTEND_NAME)

@app.route("/")
def index():
    with tracer.start_span(variables.APP_FRONTEND_NAME) as span:
        # Get the trace_id from the generated span
        trace_id = format(span.trace_id, "x")

        # Define the empty headers array
        headers = {}

        # Inject the span context into the headers array
        tracer.inject(span.context, Format.HTTP_HEADERS, headers)

        # Simulate frontend workload
        start_time = time.time()
        time.sleep(random.uniform(0.1, 2.0))

        # Call the backend
        response = requests.get(variables.APP_BACKEND_URL, headers=headers)

        # Record metrics with trace_id
        duration = time.time() - start_time
        metrics.record_request(duration, trace_id)

        # Record logs with trace_id
        message = f"[Frontend] Request from {request.remote_addr} to {variables.APP_BACKEND_URL} endpoint completed"
        logger.info(message, extra={"tags": {"trace_id": trace_id}})

        # Return with a message
        return f"Frontend received: {response.text}"


if __name__ == "__main__":
    # Start the flask based frontend web application
    app.run(debug=variables.APP_DEBUG, host=variables.APP_FRONTEND_HOST, port=variables.APP_FRONTEND_PORT)
