from opentelemetry import metrics
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

REQUEST_COUNTER = None
REQUEST_LATENCY = None
REQUEST_DURATION = None

# METRICS

def init(metrics_endpoint, app_name):
    # Define meter variables as global to be used everywhere
    global REQUEST_COUNTER, REQUEST_LATENCY, REQUEST_DURATION

    # Create OpenTelemetry resource
    otlp_resource = Resource.create(attributes={"service.name": app_name})

    # Set up OTLP exporter to send metrics to the OpenTelemetry Collector
    otlp_exporter = OTLPMetricExporter(endpoint=metrics_endpoint, insecure=True)

    # Export every second
    otlp_metric_reader = PeriodicExportingMetricReader(otlp_exporter, export_interval_millis=1000)

    # Initialize MeterProvider with the reader
    otlp_meter_provider = MeterProvider(resource=otlp_resource, metric_readers=[otlp_metric_reader])

    # Register the provider as the global one for the app
    metrics.set_meter_provider(otlp_meter_provider)

    # Get a meter instance scoped to this module
    meter = metrics.get_meter(__name__)

    # Create metrics objects
    REQUEST_COUNTER = meter.create_counter(
        f"{app_name}_requests_total",
        description="Total number of processed requests (counter)",
        unit="1")
    REQUEST_LATENCY = meter.create_histogram(
        f"{app_name}_request_latency_seconds",
        description="Latency for processing requests (histogram)",
        unit="s")
    REQUEST_DURATION = meter.create_gauge(
        f"{app_name}_request_duration_seconds",
        description="Duration for processing single request (gauge)",
        unit="s")

def record_request(duration):
    REQUEST_COUNTER.add(1)
    REQUEST_LATENCY.record(duration)
    REQUEST_DURATION.set(duration)
