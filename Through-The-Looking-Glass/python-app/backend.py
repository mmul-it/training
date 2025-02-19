import os
import time
import random
import traces
import logs
import metrics
import variables
from flask import Flask, request

# Initialize Flask App
app = Flask(variables.APP_BACKEND_NAME)

# Set up Tempo traces
trace_provider = traces.init_provider(variables.APP_BACKEND_NAME)
trace_span = traces.init_span(variables.TRACES_OTLP_ENDPOINT)
traces.init_flask(app)

# Set up Loki logs
logger = logs.init(variables.LOGS_URL, variables.APP_BACKEND_NAME)

# Set up Prometheus metrics (with /metrics endpoint)
metrics.init_metrics(app)

# Define the /process path for the application
@app.route("/process")
def process_request():

    with trace_provider.start_as_current_span(variables.APP_BACKEND_NAME):
        trace_id = trace_span.get_current_span().get_span_context().trace_id

        # Get the caller IP
        client_ip = request.remote_addr
    
        # Track the start time
        start_time = time.time()
    
        # Metrics simulate CPU time
        time.sleep(random.uniform(0, 3))
        duration = time.time() - start_time
        metrics.record_request(f"{trace_id:032x}", duration)
            
        # Logs
        message = f"Backend: Processing request from '{client_ip}' source"
        logger.info(f"{message}", extra={"tags": {"trace_id": f"{trace_id:032x}"}})
        return "Processed data in Backend!"

# Execute Flask app
if __name__ == "__main__":
    app.run(debug=True, host=variables.APP_BACKEND_HOST, port=variables.APP_BACKEND_PORT)
