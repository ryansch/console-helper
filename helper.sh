#!/bin/bash

set -euo pipefail

docker_id=null

get_docker_id() {
  docker_id=$(curl -sS "http://localhost:51678/v1/tasks?taskarn=${TASK_ARN}" \
    | jq -r "[.Containers[]? | select(.Name == \"${CONTAINER_NAME}\")] | first | .DockerId")

  echo -n .
  # echo "debug: ${docker_id}"
}

echo "-> Waiting for container to start:"

get_docker_id
while [ "$docker_id" == 'null' ] || [ "$docker_id" == '' ]; do
  get_docker_id
  sleep 1
done

echo
echo "-> Loading console on ${docker_id}"
echo "-> Running /docker-entrypoint.sh console"

# bash
docker exec -it "${docker_id}" /docker-entrypoint.sh console
