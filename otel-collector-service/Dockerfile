ARG otel_collector_version=latest

FROM otel/opentelemetry-collector-contrib:${otel_collector_version}
ARG config_type=debug

COPY configs/"${config_type}"-config.yaml /etc/otelcol-contrib/config.yaml

EXPOSE 13133