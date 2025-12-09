ARG java_version=latest

FROM eclipse-temurin:${java_version}-jre-noble

COPY opentelemetry-javaagent.jar /otel-agent/opentelemetry-javaagent.jar

ENV JAVA_TOOL_OPTIONS='-javaagent:/otel-agent/opentelemetry-javaagent.jar'

# otel general

# otel metrics
ENV OTEL_METRICS_EXPORTER=none

# otel logs
ENV OTEL_LOGS_EXPORTER=none

# otel traces
ENV OTEL_TRACES_EXPORTER=none