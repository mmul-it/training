from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.resources import Resource

REQUEST_COUNTER = None
REQUEST_LATENCY = None

def init(metrics_endpoint, app_name):
    global REQUEST_COUNTER, REQUEST_LATENCY

    # Initialize OpenTelemetry metrics
    resource = Resource.create(attributes={"service.name": app_name})
    
    # Set up OTLP exporter to send metrics to the OpenTelemetry Collector
    otlp_exporter = OTLPMetricExporter(endpoint=metrics_endpoint, insecure=True)  # Replace with your collector's endpoint
    otlp_metric_reader = PeriodicExportingMetricReader(otlp_exporter, export_interval_millis=1000)  # Export every second
    
    # Initialize MeterProvider with the reader
    provider = MeterProvider(resource=resource, metric_readers=[otlp_metric_reader])
    metrics.set_meter_provider(provider)
    
    meter = metrics.get_meter(__name__)
    
    # Define your metrics objects
    REQUEST_COUNTER = meter.create_counter(
        f"{app_name}_requests_total",
        description="Total number of processed backend requests",
        unit="1",
    )
    
    REQUEST_LATENCY = meter.create_histogram(
        f"{app_name}_request_latency_seconds",
        description="Latency for processing backend requests",
        unit="s",
    )

def record_request(duration, trace_id):
    REQUEST_COUNTER.add(1)
    REQUEST_LATENCY.record(duration, {"trace_id": f"{trace_id:032x}"})
