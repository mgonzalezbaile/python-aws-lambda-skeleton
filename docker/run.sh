#!/usr/bin/env bash

container_name=lambdas
run_command="docker run --env ANSIBLE_VAULT_PASSWORD --user ${UID} -w /var/task -v $(pwd):/var/task ${container_name}"

COMMAND=${1:-}
shift

function usage {
    cat <<EOF
Usage: $0 <COMMAND> <ARGUMENT>

Commands:
  build                 Build docker containers
  start                 Start the application services and infrastructure
  stop                  Stop the application services and infrastructure
  test                  Run tests
  deploy                Deploy artifacts
  undeploy              Remove all deployed artifacts
  exec <command>        Run the command within the container
  encrypt <file_path>   Encrypt file
  decrypt <file_path>   Decrypt file


Examples:

   $0 build
   $0 start
   $0 test
   $0 exec ls
   $0 encrypt secrets/local.yml
   $0 decrypt secrets/local.yml
EOF
}

case "$COMMAND" in
    build)
    CURRENT_UID=$(id -u):$(id -g) docker-compose -f docker/infra-docker-compose.yaml build
    CURRENT_UID=$(id -u):$(id -g) docker-compose -f docker/lambdas-docker-compose.yaml build
    ${run_command} yarn install
    cp git-hooks/pre-commit .git/hooks
    ;;

    start)
    docker-compose -f docker/infra-docker-compose.yaml up -d
    docker-compose -f docker/lambdas-docker-compose.yaml up
    ;;

    stop)
    docker-compose -f docker/infra-docker-compose.yaml stop
    docker-compose -f docker/lambdas-docker-compose.yaml stop
    ;;

    test)
    ${run_command} python -m pytest plugins/tests/
    ;;

    deploy)
    ${run_command} cp /usr/lib64/libpq.so.5 /var/task
    ${run_command} cp /usr/lib64/libpq.so.5.5 /var/task
    ${run_command} ansible-vault decrypt secrets/prod.yml
    ${run_command} chmod +r secrets/*
    ${run_command} serverless --stage prod deploy
    ${run_command} rm -r .serverless
    ;;

    undeploy)
    ${run_command} serverless --stage prod remove
    ;;

    encrypt)
    ${run_command} ansible-vault encrypt $@
    ;;

    decrypt)
    ${run_command} ansible-vault decrypt $@
    ;;

    exec)
    ${run_command} $@
    ;;

    "")
    echo "Missing command" >&2
    usage
    exit 1
    ;;
    *)

    echo "Unknown command: $COMMAND" >&2
    usage
    exit 1
    ;;
esac
