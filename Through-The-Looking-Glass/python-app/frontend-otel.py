import os
import requests
import traces
import logs
import variables
from flask import Flask

# Initialize Flask App
app = Flask(variables.APP_FRONTEND_NAME)

# Set up Tempo traces
trace_provider = traces.init_provider(variables.APP_FRONTEND_NAME)
trace_span = traces.init_span(variables.TRACES_ENDPOINT)
traces.init_flask(app)

# Set up Loki logs
logger = logs.init(variables.LOGS_ENDPOINT, variables.APP_FRONTEND_NAME)

@app.route("/")
def index():
    with trace_provider.start_as_current_span(variables.APP_FRONTEND_NAME):
        trace_id = trace_span.get_current_span().get_span_context().trace_id

        # Call the backend
        response = requests.get(variables.APP_BACKEND_URL)
    
        # Logs
        message = f"Frontend: request at '{variables.APP_BACKEND_URL}' endpoint completed"
        logger.info(f"{message}")
        return f"Frontend received: {response.text}"

if __name__ == "__main__":
    app.run(debug=variables.APP_DEBUG, host=variables.APP_FRONTEND_HOST, port=variables.APP_FRONTEND_PORT)
