#!/bin/bash

image=$1
env=$2

otel-collector-service() {
  OTEL_COLLECTOR_CONTRIB_VERSION=${3:-$(yq '.otel-collector-contrib.version' ./otel-collector-service/version.yaml)}
  IMAGE_TAG_SUFFIX=${4:-latest}
  echo "otel-collector-contrib.version: $OTEL_COLLECTOR_CONTRIB_VERSION"
  echo "env: $env"

  if [ "${env}" == "local" ]; then
    docker build --no-cache -t local/otel-collector-service:latest --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" ./otel-collector-service/

  elif [ "${env}" == "test" ]; then
    IMAGE_TAG="$OTEL_COLLECTOR_CONTRIB_VERSION"-"$IMAGE_TAG_SUFFIX"
    docker build --no-cache -t "$REGISTRY/$REPOSITORY:$IMAGE_TAG" --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" ./otel-collector-service/
    docker image push -a "$REGISTRY/$REPOSITORY"
    echo "image=$REGISTRY/$REPOSITORY:$IMAGE_TAG" >> "$GITHUB_OUTPUT"

  elif [ "${env}" == "prod" ]; then
    docker build --no-cache -t "$REGISTRY/$REPOSITORY:$OTEL_COLLECTOR_CONTRIB_VERSION" -t "$REGISTRY/$REPOSITORY":latest --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" ./otel-collector-service/
    docker image push -a "$REGISTRY/$REPOSITORY"
    echo "image=$REGISTRY/$REPOSITORY:$OTEL_COLLECTOR_CONTRIB_VERSION" >> "$GITHUB_OUTPUT"

  else
    echo "Please select a env: local, test, prod"
  fi
}

otel-java-agent() {
  JAVA_VERSION=${3:-$(yq '.java.version' ./otel-java-agent/version.yaml)}
  OTEL_JAVA_AGENT_VERSION=${4:-$(yq '.otel-java-agent.version' ./otel-java-agent/version.yaml)}
  echo "java.version: $JAVA_VERSION"
  echo "otel-java-agent.version: $OTEL_JAVA_AGENT_VERSION"
  echo "env: $env"
  wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v"${OTEL_JAVA_AGENT_VERSION}"/opentelemetry-javaagent.jar -P ./otel-java-agent

  if [ "${env}" == "local" ]; then
    docker build --no-cache -t local/otel-java-agent:latest --build-arg java_version="${JAVA_VERSION}" ./otel-java-agent/
    rm ./otel-java-agent/opentelemetry-javaagent.jar

  elif [ "${env}" == "prod" ]; then
    docker build --no-cache -t "$REGISTRY/$REPOSITORY:$JAVA_VERSION-$OTEL_JAVA_AGENT_VERSION" --build-arg java_version="${JAVA_VERSION}" ./otel-java-agent/
    docker image push -a "$REGISTRY/$REPOSITORY"

  else
    echo "Please select a env: local, prod"
  fi
}

if [ "${image}" == "all" ]; then
  otel-collector-service "$@";otel-java-agent "$@"
elif [ "${image}" == "otel-collector-service" ]; then
  otel-collector-service "$@"
elif [ "${image}" == "otel-java-agent" ]; then
  otel-java-agent "$@"
else
  echo "Please select an image: all, otel-collector-service, otel-java-agent"
fi