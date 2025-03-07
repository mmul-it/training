import os
import logging
import logging_loki
import requests

# LOGS
def init(logger_url, app_name):
    loki_url = logger_url

    handler = logging_loki.LokiHandler(
        url=loki_url,
        tags={"application": app_name},
        version="1",
    )

    logger = logging.getLogger(app_name)

    logging.basicConfig(level=logging.INFO)

    logger.addHandler(handler)

    return logger
