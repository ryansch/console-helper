#!/bin/bash

set -euo pipefail

docker_id=null

get_docker_id() {
  docker_id=$(curl -sS "http://localhost:51678/v1/tasks?taskarn=${TASK_ARN}" \
    | jq -r "[.Containers[]? | select(.Name == \"${CONTAINER_NAME}\")] | first | .DockerId")

  if [ "${DEBUG:-}" == "true" ]; then
    echo "debug: ${docker_id}"
  elif [ "${TASK_STATUS:-}" != "true" ]; then
    echo -n .
  fi
}

echo "-> Waiting for container to start:"

get_docker_id
while [ "$docker_id" == 'null' ] || [ "$docker_id" == '' ]; do
  get_docker_id

  if [ "${TASK_STATUS:-}" == "true" ]; then
    output=$(aws ecs describe-tasks --region us-east-1 --cluster prod-green --tasks "${TASK_ARN}" \
      | jq -r '.tasks[0] | "Task Status: \(.lastStatus)", "", (.containers[] | "\(.name): \(.lastStatus)")')

    if [ -n "${length:-}" ]; then
      for i in $(seq "$length")
      do
        tput cuu1 # move cursor up by one line
        tput el # clear the line
      done
    fi

    length=$(echo "$output" | wc -l)
    echo "$output"
  fi

  sleep 1
done

echo
echo "-> Loading console on ${docker_id}"

if [ "${BASH_SHELL:-}" == "true" ]; then
  echo "-> Running a bash shell on the container instance"
  bash
else
  echo "-> Running /docker-entrypoint.sh console"
  docker exec -it "${docker_id}" /docker-entrypoint.sh console
fi
