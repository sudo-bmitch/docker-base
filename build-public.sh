#!/bin/sh

set -e

REGISTRY=docker.io
BASE_REPOSITORY=sudobmitch/base
build_date=$(date +%Y%m%d-%H%M%S)
vcs_ref="undef"
vcs_url="https://github.com/sudo-bmitch/base"

common_args=""
common_args="${common_args} --label org.label-schema.build-date=${build_date}"
common_args="${common_args} --label org.label-schema.vcs-ref=${vcs_ref}"
common_args="${common_args} --label org.label-schema.vcs-url=${vcs_url}"
common_args="${common_args} --build-arg REGISTRY=${REGISTRY}"
common_args="${common_args} --build-arg BASE_REPOSITORY=${BASE_REPOSITORY}"

docker build ${common_args} -t ${REGISTRY}/${BASE_REPOSITORY}/base:debian  -f Dockerfile.debian  .
docker build ${common_args} -t ${REGISTRY}/${BASE_REPOSITORY}/base:alpine  -f Dockerfile.alpine  .
docker build ${common_args} -t ${REGISTRY}/${BASE_REPOSITORY}/base:scratch -f Dockerfile.scratch .

