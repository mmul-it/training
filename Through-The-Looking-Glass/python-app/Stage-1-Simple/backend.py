import os
import time
import random
import logging

import variables

from flask import Flask, request

# Initialize Flask App
app = Flask(variables.APP_BACKEND_NAME)

logging.basicConfig(level=logging.INFO)

# Define the /process path for the application
@app.route("/process")
def process_request():
        # Get the caller IP
        client_ip = request.remote_addr

        # Simulate CPU time
        start_time = time.time()
        time.sleep(random.uniform(0.1, 2.0))
        duration = time.time() - start_time

        # Logs
        message = f"Backend: Processing request from '{client_ip}' source. Took {duration} seconds."
        logging.info(f"{message}")
        return "Processed data in Backend!"

# Execute Flask app
if __name__ == "__main__":
    app.run(debug=variables.APP_DEBUG, host=variables.APP_BACKEND_HOST, port=variables.APP_BACKEND_PORT)
