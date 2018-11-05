#!/bin/sh

docker build -f Dockerfile.mainline -t localhost:5000/nginx:mainline .
docker build -f Dockerfile.alpine   -t localhost:5000/nginx:alpine   .

