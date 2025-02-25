# Lab | Observability Multiple Choice Quiz

In this lab you will be asked ten questions about Observability, only one answer
is correct for each question.

## Questions

1. **What is the main goal of observability in modern cloud environments?**
    1. To replace logs with dashboards
    2. To ensure applications run without any errors
    3. To provide deep visibility into system behavior through logs, metrics,
        and traces
    4. To monitor infrastructure without tracking applications
2. **Which of the following is NOT a key pillar of observability?**
    1. Logs
    2. Traces
    3. Metrics
    4. Configuration files
3. **What is OpenTelemetry primarily used for?**
    1. Configuring Kubernetes clusters
    2. Providing a vendor-agnostic observability framework for collecting
        telemetry data
    3. Managing cloud costs
    4. Encrypting network traffic
4. **In a microservices architecture, what does a trace help identify?**
    1. CPU and memory usage of a container
    2. The execution flow of a request across multiple services
    3. Network firewall configurations
    4. The number of users accessing the system
5. **Why is context propagation important in distributed tracing?**
    1. It allows microservices to communicate without network latency
    2. It ensures that logs are stored in separate files for each service
    3. It carries the Trace ID across services to maintain a complete request
        flow
    4. It automatically fixes slow response times in services
6. **Where can you typically find the Trace ID in an OpenTelemetry-instrumented
   system?**
    1. Only in the Jaeger UI
    2. Inside logs, tracing dashboards, and HTTP headers
    3. Only inside Kubernetes pod definitions
    4. In database queries
7. **Which of these statements about OpenTelemetry is TRUE?**
    1. It is a proprietary tool developed by Google
    2. It is an open-source project that standardizes observability data
        collection
    3. It only works with Prometheus
    4. It replaces the need for logs in applications
8. **How does OpenTelemetry reduce vendor lock-in?**
    1. By allowing organizations to use any cloud provider
    2. By providing a unified API and SDKs for collecting telemetry data
        independent of backend tools
    3. By automatically selecting the best observability tool for each
        organization
    4. By restricting its use to Kubernetes environments only
9. **What is a key cultural change when adopting OpenTelemetry?**
    1. Developers must manually log every event instead of using traces
    2. Only the operations team is responsible for observability
    3. Developers must design applications with telemetry in mind and ensure
        trace context propagation
    4. Observability is no longer needed for debugging applications
10. **What is a common best practice for improving observability with
    OpenTelemetry?**
    1. Injecting Trace IDs into logs to correlate them with traces
    2. Disabling automatic instrumentation to reduce overhead
    3. Removing all logs and relying only on traces
    4. Using OpenTelemetry only in production environments

## Answers

1. **3** - Observability is about gaining deep visibility into system
   behavior through **logs, metrics, and traces**, which helps understand and
   troubleshoot issues.
2. **4** - Configuration files are important for system setup but are **not**
   one of the three key pillars of observability **logs, metrics, traces).
3. **2** - OpenTelemetry is a **vendor-agnostic** framework designed for
   **collecting, generating, and exporting telemetry data** **logs, metrics, and
   traces).
4. **2** - A **trace** helps identify the **flow of a request** across
   multiple services, making it easier to debug performance issues in
   microservices architectures.
5. **3** - **Context propagation** is crucial because it carries the
   **Trace ID across services**, ensuring that distributed tracing remains
   intact.
6. **2** - The **Trace ID** can be found in **logs, tracing dashboards
   **Jaeger, Tempo, etc.), and HTTP headers**, helping correlate observability
   data.
7. **2** - OpenTelemetry is an **open-source standard** that provides a
   unified way to collect observability data, making it **not tied to any single
   vendor**.
8. **2** - OpenTelemetry reduces **vendor lock-in** by offering **a
   standardized API and SDKs**, allowing organizations to **switch backends**
   **e.g., Jaeger, Datadog, Prometheus) without modifying instrumentation.
9. **3** - OpenTelemetry requires a **cultural shift**, where **developers
   must design applications with telemetry in mind**, ensuring that **trace
   context is propagated** across services.
10. **1** - A **best practice** in observability is to **inject Trace IDs
    into logs**, allowing teams to correlate logs and traces for more effective
    debugging.
