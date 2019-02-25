#!/bin/sh

REGISTRY=localhost:5000/bmitch-public
BASE_REPOSITORY=base
build_date=$(date +%Y%m%d-%H%M%S)
vcs_ref="undef"
vcs_url="undef"

common_args=""
common_args="${common_args} --label org.label-schema.build-date=${build_date}"
common_args="${common_args} --label org.label-schema.vcs-ref=${vcs_ref}"
common_args="${common_args} --label org.label-schema.vcs-url=${vcs_url}"
common_args="${common_args} --build-arg REGISTRY=${REGISTRY}"
common_args="${common_args} --build-arg BASE_REPOSITORY=${BASE_REPOSITORY}"

docker build ${common_args} -t ${REGISTRY}/${BASE_REPOSITORY}:debian  -f Dockerfile.debian  .
docker build ${common_args} -t ${REGISTRY}/${BASE_REPOSITORY}:alpine  -f Dockerfile.alpine  .
docker build ${common_args} -t ${REGISTRY}/${BASE_REPOSITORY}:scratch -f Dockerfile.scratch .

