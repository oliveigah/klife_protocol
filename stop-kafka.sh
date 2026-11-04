#!/bin/bash

VERSION=${1:-"4.0"}

docker compose -f ./test/compose_files/docker-compose-kafka-${VERSION}.yml down --volumes
