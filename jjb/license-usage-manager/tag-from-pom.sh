#!/bin/bash


# For use as a JJB docker-get-container-tag-script
# Use the project/version from a pom.xml as the tag for the docker image
# By default, look for the pom.xml in the same directory as the Dockerfile.
# This can be overridden by setting container-tag-yaml-dir

set -feu -o pipefail

echo "--> tag-from-pom.sh"

tag=$(xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -m "/x:project" -v x:version ${CONTAINER_TAG_YAML_DIR:-$DOCKER_ROOT}/pom.xml)
tag=${tag%-*}

echo "INFO: Docker tag is $tag"

echo "DOCKER_IMAGE_TAG=$tag" >> "$WORKSPACE/env_docker_inject.txt"
