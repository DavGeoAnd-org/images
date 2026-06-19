#!/bin/bash

cd "$(dirname "$0")" || exit

ENV=${1:-local}
OTEL_COLLECTOR_CONTRIB_VERSION=${2:-$(yq '.otel-collector-contrib.version' ./version.yaml)}
IMAGE_TAG_SUFFIX=$3

echo "ENV: $ENV"
echo "OTEL_COLLECTOR_CONTRIB_VERSION: $OTEL_COLLECTOR_CONTRIB_VERSION"
echo "IMAGE_TAG_SUFFIX: $IMAGE_TAG_SUFFIX"

if [ "${ENV}" == "local" ]; then
    docker build --no-cache -t local/otel-collector-service:latest --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" .

elif [ "${ENV}" == "test" ]; then
    docker build --no-cache -t "${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}-${IMAGE_TAG_SUFFIX}" --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" .
    docker image push -a "${REGISTRY}/${REPOSITORY}"
    echo "image=${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}-${IMAGE_TAG_SUFFIX}" >> "$GITHUB_OUTPUT"

elif [ "${ENV}" == "prod" ]; then
    docker build --no-cache -t "${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}" -t "${REGISTRY}/${REPOSITORY}:latest" --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" .
    docker image push -a "${REGISTRY}/${REPOSITORY}"
    echo "image=${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}" >> "$GITHUB_OUTPUT"

else
    echo "Please select a env: local, test, prod"
fi




