from jaeger_client import Config

# TRACES

def init_tracer(traces_endpoint, app_name):
    # Extract endpoint host and port
    traces_host, traces_port = traces_endpoint.split(":")

    # Configure jaeger client
    config = Config(
        config={
            'sampler': {'type': 'const', 'param': 1},
            'logging': False,
            'local_agent': {
                'reporting_host': traces_host,
                'reporting_port': int(traces_port),
            },
        },
        service_name=app_name,
        validate=True,
    )

    # Initialize tracer
    tracer = config.initialize_tracer()

    # Return the configured tracer so it can be used elsewhere
    return tracer
