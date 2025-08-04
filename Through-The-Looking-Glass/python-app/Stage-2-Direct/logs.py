import logging
import logging_loki

# LOGS

def init(logs_endpoint, app_name):
    # Create a Loki log handler that adds a tag "application=<app_name>" to help
    # identify logs in Loki
    loki_handler = logging_loki.LokiHandler(url=logs_endpoint, tags={"application": app_name}, version="2")

    # Get or create a logger instance with the given application name
    logger = logging.getLogger(app_name)

    # Set the default logging level to INFO, logs with level INFO and above
    # (e.g., WARNING, ERROR) will be handled
    logging.basicConfig(level=logging.INFO)

    # Attach the Loki handler to the logger, this is what makes logs go to the
    # Loki backend
    logger.addHandler(loki_handler)

    # Return the configured logger so it can be used elsewhere
    return logger
