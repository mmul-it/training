from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.flask import FlaskInstrumentor

# Set APP_NAME reading file name
def init_provider(service_name):
    # Set up Tracer
    trace.set_tracer_provider(
        TracerProvider(
            resource=Resource(attributes={"service.name": service_name})
        )
    )

    tracer = trace.get_tracer(service_name)

    return tracer

def init_span(otlp_endpoint):
    tempo_exporter = OTLPSpanExporter(
        endpoint = otlp_endpoint,
        insecure = True
    )

    trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(tempo_exporter))

    return trace

def init_flask(flask_app):
    FlaskInstrumentor().instrument_app(flask_app)
    RequestsInstrumentor().instrument()  # Instrument outgoing HTTP requests
