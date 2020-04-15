#!/bin/bash

set -feu -o pipefail

echo "--> tag-from-pom.sh"

tag=$(xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -m "/x:project" -v x:version ${CONTAINER_TAG_YAML_DIR:-$DOCKER_ROOT}/pom.xml)

echo "INFO: Docker tag is $tag"

echo "DOCKER_IMAGE_TAG=$tag" >> "$WORKSPACE/env_docker_inject.txt"
