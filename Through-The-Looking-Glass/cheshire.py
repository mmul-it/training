import os
import traces
import logs
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

# Define the /process path for the application
@app.route("/process")
def process_request():
    client_ip = request.remote_addr

    with trace_provider.start_as_current_span(variables.APP_BACKEND_NAME):
        trace_id = trace_span.get_current_span().get_span_context().trace_id
        message = f"Backend: Processing request from '{client_ip}' endpoint"
        logger.info(f"{message}", extra={"tags": {"trace_id": f"{trace_id:032x}"}})
        return "Processed data in Backend!"

# Execute Flask app
if __name__ == "__main__":
    app.run(debug=True, port=variables.APP_FRONTEND_PORT)
