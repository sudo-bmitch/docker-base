#!/bin/sh

REPOSITORY=localhost:5000
build_date=$(date +%Y%m%d-%H%M%S)
vcs_ref="undef"
vcs_url="undef"

common_args=""
common_args="${common_args} --label org.label-schema.build-date=${build_date}"
common_args="${common_args} --label org.label-schema.vcs-ref=${vcs_ref}"
common_args="${common_args} --label org.label-schema.vcs-url=${vcs_url}"
common_args="${common_args} --build-arg REPOSITORY=${REPOSITORY}"

docker build ${common_args} -t ${REPOSITORY}/base:debian  -f Dockerfile.debian  .
docker build ${common_args} -t ${REPOSITORY}/base:alpine  -f Dockerfile.alpine  .
docker build ${common_args} -t ${REPOSITORY}/base:scratch -f Dockerfile.scratch .

