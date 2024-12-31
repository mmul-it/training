import os
import logging
import logging_loki
import requests
from flask import Flask
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.flask import FlaskInstrumentor
# Deprecated
# from opentelemetry.exporter.jaeger.thrift import JaegerExporter
#from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Set APP_NAME reading file name
APP_NAME = os.path.splitext(os.path.basename(__file__))[0]

# Set up Tracer
trace.set_tracer_provider(
    TracerProvider(
        resource=Resource(attributes={"service.name": APP_NAME})
    )
)
tracer = trace.get_tracer(APP_NAME)

## Deprecated
# Configure Jaeger Exporter
# jaeger_exporter = JaegerExporter(
#     agent_host_name="localhost",
#     agent_port=6831,
# )
## Not working (there seems to be no way to send traces from Jager to Tempo)
#jaeger_exporter = OTLPSpanExporter(
#    endpoint="http://172.18.0.105:4318/v1/traces"
#    endpoint = "172.18.0.105:4317",
#    insecure = True
#)
#trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(jaeger_exporter))
tempo_exporter = OTLPSpanExporter(
    endpoint = "172.18.0.102:4317",
    insecure = True
)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(tempo_exporter))

# LOGS
loki_url = "http://172.18.0.104:8080/loki/api/v1/push"
handler = logging_loki.LokiHandler(
    url=loki_url,
    tags={"application": APP_NAME},
    version="1",
)
logger = logging.getLogger(APP_NAME)
logging.basicConfig(level=logging.INFO)
logger.addHandler(handler)

# Initialize Flask App
app = Flask(APP_NAME)
FlaskInstrumentor().instrument_app(app)

# Define the /process path for the application
@app.route("/process")
def process_request():
    with tracer.start_as_current_span(APP_NAME):
        logger.info("Backend: Processing request at '/process' endpoint")
        return "Processed data in Backend!"

# Execute Flask app
if __name__ == "__main__":
    app.run(debug=True, port=5001)

