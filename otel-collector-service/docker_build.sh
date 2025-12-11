#!/bin/bash

cd "$(dirname "$0")" || exit

CONFIG_TYPE=${1:-debug}
ENV=${2:-local}
OTEL_COLLECTOR_CONTRIB_VERSION=${3:-$(yq '.otel-collector-contrib.version' ./version.yaml)}
IMAGE_TAG_SUFFIX=$4

echo "CONFIG_TYPE: $CONFIG_TYPE"
echo "ENV: $ENV"
echo "OTEL_COLLECTOR_CONTRIB_VERSION: $OTEL_COLLECTOR_CONTRIB_VERSION"
echo "IMAGE_TAG_SUFFIX: $IMAGE_TAG_SUFFIX"

build() {
  if [ "${ENV}" == "local" ]; then
      docker build --no-cache -t local/otel-collector-service:latest --build-arg config_type="${CONFIG_TYPE}" --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" .

  elif [ "${ENV}" == "test" ]; then
      docker build --no-cache -t "${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}-${CONFIG_TYPE}-${IMAGE_TAG_SUFFIX}" --build-arg config_type="${CONFIG_TYPE}" --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" .
      docker image push -a "${REGISTRY}/${REPOSITORY}"
      echo "image=${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}-${CONFIG_TYPE}-${IMAGE_TAG_SUFFIX}" >> "$GITHUB_OUTPUT"

  elif [ "${ENV}" == "prod" ]; then
      docker build --no-cache -t "${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}-${CONFIG_TYPE}" -t "${REGISTRY}/${REPOSITORY}:latest-${CONFIG_TYPE}" --build-arg config_type="${CONFIG_TYPE}" --build-arg otel_collector_version="${OTEL_COLLECTOR_CONTRIB_VERSION}" .
      docker image push -a "${REGISTRY}/${REPOSITORY}"
      echo "image=${REGISTRY}/${REPOSITORY}:${OTEL_COLLECTOR_CONTRIB_VERSION}-${CONFIG_TYPE}" >> "$GITHUB_OUTPUT"

  else
      echo "Please select a env: local, test, prod"
  fi
}

config_types="debug nr graf"
if [[ " $config_types " =~ $CONFIG_TYPE ]]; then
  build
else
  echo "Please select a config type: $config_types"
fi



