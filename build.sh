#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

export BUILD_REPOSITORY_TAG=$(getRepositoryTag)   
                                                       
IMAGE_TAG="${BUILD_REPOSITORY_TAG:-latest}" 

sleep $SLEEP_DURATION

# Check required environment variables
if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" || -z "$IMAGE_NAME" || -z "$IMAGE_TAG" ]]; then
  echo "One or more required environment variables are missing."
  echo "Please set DOCKER_USERNAME, DOCKER_PASSWORD, IMAGE_NAME."
  exit 1
fi

push_image() {
  echo "Logging in to Docker Hub..."
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  echo "Pushing image to Docker Hub..."
  docker push "$DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG"
  echo "Image pushed: $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG"
}

push_image