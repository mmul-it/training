import os
import time
import random
import logging
import requests

import variables

from flask import Flask, request

# Initialize Flask App
app = Flask(variables.APP_FRONTEND_NAME)

# Initialize basic logging
logging.basicConfig(level=logging.INFO)

# Define the / path for the application
@app.route("/")
def index():
        # Get the caller IP
        client_ip = request.remote_addr

        # Simulate CPU time
        start_time = time.time()
        time.sleep(random.uniform(0.1, 2.0))
        duration = time.time() - start_time

        # Call the backend
        response = requests.get(variables.APP_BACKEND_URL)

        # Logs
        message = f"Frontend: request from '{client_ip}', calling '{variables.APP_BACKEND_URL}' endpoint completed. Took {duration} seconds."
        logging.info(f"{message}")
        return f"Frontend received: {response.text}"

if __name__ == "__main__":
    app.run(debug=variables.APP_DEBUG, host=variables.APP_FRONTEND_HOST, port=variables.APP_FRONTEND_PORT)
