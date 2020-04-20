#!/bin/bash


# For use as a JJB docker-get-container-tag-script
# Use the project/version from a pom.xml as the tag for the docker image
# By default, look for the pom.xml in the same directory as the Dockerfile.
# This can be overridden by setting container-tag-yaml-dir
# This is used in a mixed-language project.  The Java component uses the
# Maven convention of having -SNAPSHOT on version numbers with stage-release.
# The non-Java components don't have stage-release so the -SNAPSHOT is
# stripped from the pom.xml file's version number, when building those
# components, here

set -feu -o pipefail

echo "--> tag-from-pom.sh"

tag=$(xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -m "/x:project" -v x:version ${CONTAINER_TAG_YAML_DIR:-$DOCKER_ROOT}/pom.xml)
tag=${tag%-*}

echo "INFO: Docker tag is $tag"

echo "DOCKER_IMAGE_TAG=$tag" >> "$WORKSPACE/env_docker_inject.txt"
