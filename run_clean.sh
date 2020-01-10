#!/bin/bash

cleanup() {
  echo "remove various files"
}

docker_run() {
  echo "docker-compose up --build --remote-orphan; docker run -it bootstrap_ubuntu;"
  docker-compose up --build --remove-orphan
  docker run -it bootstrap_ubuntu
}

docker_refresh() {
  echo "docker system prune; docker container prune"
  docker system prune
  docker container prune
}

main() {
  echo "by passing main to avoid run_cleanup.sh bash parsing errors"
}

main "[@]"

docker_refresh
docker_run
