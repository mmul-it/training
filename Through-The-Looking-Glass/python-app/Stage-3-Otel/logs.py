import logging

from opentelemetry._logs import set_logger_provider
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
#from opentelemetry.sdk._logs.export import ConsoleLogExporter
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.sdk.resources import Resource

# LOGS
def init(logger_url, app_name):
    logger_provider = LoggerProvider(
        resource=Resource.create(
            {
                "service.name": app_name,
            }
        ),
    )
    set_logger_provider(logger_provider)

    otlp_exporter = OTLPLogExporter(endpoint=logger_url, insecure=True)

    logger_provider.add_log_record_processor(BatchLogRecordProcessor(otlp_exporter))

    # Log to the console
    #console_exporter = ConsoleLogExporter()
    #logger_provider.add_log_record_processor(BatchLogRecordProcessor(console_exporter))

    handler = LoggingHandler(level=logging.NOTSET, logger_provider=logger_provider)

    # Attach OTLP handler to root logger
    logging.getLogger(app_name).addHandler(handler)

    # Set logging level
    logging.getLogger(app_name).setLevel(logging.INFO)

    return logging.getLogger(app_name)
