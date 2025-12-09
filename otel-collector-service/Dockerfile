ARG otel_collector_version=latest

FROM otel/opentelemetry-collector-contrib:${otel_collector_version}

COPY config.yaml /etc/otelcol-contrib/config.yaml

EXPOSE 13133