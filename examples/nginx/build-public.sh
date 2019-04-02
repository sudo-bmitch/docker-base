#!/bin/sh

docker build -f Dockerfile.mainline -t ${REPOSITORY:-localhost:5000}/nginx:mainline .
docker build -f Dockerfile.alpine   -t ${REPOSITORY:-localhost:5000}/nginx:alpine   .

