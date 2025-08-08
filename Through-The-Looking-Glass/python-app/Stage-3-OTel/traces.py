from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.flask import FlaskInstrumentor

# TRACES

def init_provider(app_name):
    # Create a Resource with service metadata (used for trace correlation and identification)
    otlp_resource = Resource.create(attributes={"service.name": app_name})

    # Initialize TracerProvider
    otlp_tracer_provider = TracerProvider(resource=otlp_resource)

    # Initialize the global TracerProvider with the defined resource
    trace.set_tracer_provider(otlp_tracer_provider)

    # Get a tracer instance for the application (used to create spans)
    tracer = trace.get_tracer(app_name)

    return tracer

def init_span(otlp_endpoint):
    # Create an OTLP exporter to send spans to the specified backend (e.g., Tempo)
    otlp_exporter = OTLPSpanExporter(endpoint=otlp_endpoint, insecure=True)

    # Add a batch processor to handle span exporting efficiently
    trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

    # Return the trace module for further use (optional, could be used to create spans)
    return trace

def init_flask(flask_app):
    # Automatically instrument Flask app to generate spans for incoming HTTP requests
    FlaskInstrumentor().instrument_app(flask_app)

    # Automatically instrument HTTP client requests (e.g., requests.get)
    RequestsInstrumentor().instrument()
