import logging

from opentelemetry import _logs
from opentelemetry.sdk.resources import Resource
#from opentelemetry.sdk._logs.export import ConsoleLogExporter
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter

# LOGS

def init(logger_url, app_name):
    # Create OpenTelemetry resource
    otlp_resource = Resource.create(attributes={"service.name": app_name})

    # Create a logger provider with the service name as a resource attribute
    otlp_logger_provider = LoggerProvider(resource=otlp_resource)

    # Set the created logger provider as the global provider
    _logs.set_logger_provider(otlp_logger_provider)

    # Create an OTLP exporter to send logs to the specified logger URL
    otlp_exporter = OTLPLogExporter(endpoint=logger_url, insecure=True)

    # Add a batch processor to send logs using the OTLP exporter
    otlp_logger_provider.add_log_record_processor(BatchLogRecordProcessor(otlp_exporter))

    # Log to the console (optional, commented out)
    #console_exporter = ConsoleLogExporter()
    #logger_provider.add_log_record_processor(BatchLogRecordProcessor(console_exporter))

    # Create a logging handler using the custom logger provider
    handler = LoggingHandler(level=logging.NOTSET, logger_provider=otlp_logger_provider)

    # Attach OTLP handler to the application's logger
    logging.getLogger(app_name).addHandler(handler)

    # Set logging level to INFO for the application's logger
    logging.getLogger(app_name).setLevel(logging.INFO)

    return logging.getLogger(app_name)
