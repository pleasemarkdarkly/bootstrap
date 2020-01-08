#!/bin/bash

cleanup() {
  echo "remove various files"
}

docker_run() {
  docker-compose up --build --remove-orphan
  docker run -it bootstrap_ubuntu
}

docker_refresh() {
  docker system prune
  docker container prune
}

main() {
  echo "by passing main to avoid run_cleanup.sh bash parsing errors"
}

main "[@]"

docker_refresh
docker_run
