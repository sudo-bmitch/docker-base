#!/bin/sh

set -e

: "${REGISTRY:=docker.io}"
: "${REPOSITORY:=sudobmitch/base}"
: "${vcs_ref:=undef}"
: "${vcs_url:=https://github.com/sudo-bmitch/base}"
build_date=$(date +%Y%m%d-%H%M%S)
timestamp=$(date +%Y%m%d-%H%M%S)

common_args=""
common_args="${common_args} --label org.label-schema.build-date=${build_date}"
common_args="${common_args} --label org.label-schema.vcs-ref=${vcs_ref}"
common_args="${common_args} --label org.label-schema.vcs-url=${vcs_url}"
common_args="${common_args} --build-arg REGISTRY=${REGISTRY}"
common_args="${common_args} --build-arg REPOSITORY=${REPOSITORY}"

docker build ${common_args} -t ${REGISTRY}/${REPOSITORY}/base:debian  --target debian-base  .
docker build ${common_args} -t ${REGISTRY}/${REPOSITORY}/base:alpine  --target alpine-base  .
docker build ${common_args} -t ${REGISTRY}/${REPOSITORY}/base:scratch --target scratch-base .

