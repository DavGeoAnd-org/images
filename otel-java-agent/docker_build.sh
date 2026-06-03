#!/bin/bash

cd "$(dirname "$0")" || exit

ENV=${1:-local}
JAVA_VERSION=${2:-$(yq '.java.version' ./version.yaml)}
OTEL_JAVA_AGENT_VERSION=${3:-$(yq '.otel-java-agent.version' ./version.yaml)}

echo "ENV: $ENV"
echo "JAVA_VERSION: $JAVA_VERSION"
echo "OTEL_JAVA_AGENT_VERSION: $OTEL_JAVA_AGENT_VERSION"

downloadOtelJavaAgent() {
    wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v"${OTEL_JAVA_AGENT_VERSION}"/opentelemetry-javaagent.jar -P .
}

if [ "${ENV}" == "local" ]; then
    downloadOtelJavaAgent
    docker build --no-cache -t "local/otel-java-agent:$JAVA_VERSION-$OTEL_JAVA_AGENT_VERSION" --build-arg java_version="${JAVA_VERSION}" .
    rm ./opentelemetry-javaagent.jar

elif [ "${ENV}" == "prod" ]; then
    downloadOtelJavaAgent
    docker build --no-cache -t "$REGISTRY/$REPOSITORY:$JAVA_VERSION-$OTEL_JAVA_AGENT_VERSION" --build-arg java_version="${JAVA_VERSION}" .
    docker image push -a "$REGISTRY/$REPOSITORY"

else
    echo "Please select a env: local, prod"
fi