#!/usr/bin/env bash
export IMAGE=$1
docker-copmose -f docker-copmose.yaml up --detach
echo "OK"
