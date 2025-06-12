#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

export BUILD_REPOSITORY_TAG=$(getRepositoryTag)
export DOCKER_LINK=$(getComponentName)

IMAGE_TAG="${BUILD_REPOSITORY_TAG:-latest}"

sleep ${SLEEP_DURATION:-5}

docker_hub_push_image() {
  CONFIG_FILE="$HOME/.docker/config.json"
  DOCKER_HUB_KEY="https://index.docker.io/v1/"

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Docker config file not found: $CONFIG_FILE"
    return 1
  fi

  AUTH_LINE=$(grep -A1 "\"$DOCKER_HUB_KEY\"" "$CONFIG_FILE" | grep '"auth"')
  AUTH_TOKEN=$(echo "$AUTH_LINE" | sed -E 's/.*"auth": *"(.*)".*/\1/')

  if [ -z "$AUTH_TOKEN" ]; then
    echo "No Docker Hub auth token found in $CONFIG_FILE"
    return 1
  fi

  DECODED=$(echo "$AUTH_TOKEN" | base64 -d 2>/dev/null)
  USERNAME=$(echo "$DECODED" | cut -d':' -f1)
  PASSWORD=$(echo "$DECODED" | cut -d':' -f2-)
  DOCKER_URL=$(echo "$DOCKER_LINK" | sed "s|docker.io/|docker.io/${USERNAME}/|")

  echo "Docker push url $DOCKER_URL"

  if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Failed to extract Docker Hub username or password"
    return 1
  fi

  echo "Logging in to Docker Hub as $USERNAME..."
echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin

if [ $? -ne 0 ]; then
  echo "Docker login failed"
  return 1
else
  echo "Docker login successful for user: $USERNAME"
fi

  if [[ -z "$DOCKER_URL" || -z "$IMAGE_TAG" ]]; then
    echo "Required environment variables DOCKER_URL or IMAGE_TAG are missing"
    return 1
  fi

  echo "Pushing image to Docker Hub..."
  docker push "${DOCKER_URL}:${IMAGE_TAG}"

  if [ $? -eq 0 ]; then
    echo "Image pushed successfully: ${DOCKER_URL}:${IMAGE_TAG}"
  else
    echo "Failed to push image."
    return 1
  fi
}

docker_hub_push_image


#   Automatically log in to Docker Hub using credentials from the Docker config file and push a tagged image to the specified repository
