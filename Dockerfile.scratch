ARG BASE_REPOSITORY=sudobmitch/base
ARG REGISTRY=docker.io
FROM ${REGISTRY}/${BASE_REPOSITORY}:debian as build

FROM scratch

COPY --from=build \
     /usr/bin/wait-for-it.sh \
     /usr/bin/tini \
     /usr/bin/gosu \
     /usr/bin/fix-perms \
     /usr/bin/secret-vars \
     /usr/bin/entrypointd.sh \
     /usr/bin/healthcheckd.sh \
     /usr/bin/load-volume \
     /usr/bin/save-volume \
     /usr/bin/

COPY --from=build /etc/entrypoint.d/  /etc/entrypoint.d/
COPY --from=build /etc/healthcheck.d/ /etc/healthcheck.d/

ARG IMAGE_VERSION=1.0.0
ARG BASE_REPOSITORY=sudobmitch/base
LABEL \
    org.label-schema.description="Base image for scratch" \
    org.label-schema.name="${REGISTRY}/${BASE_REPOSITORY}:scratch" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/sudo-bmitch/docker-images" \
    org.label-schema.vendor="Brandon Mitchell" \
    org.label-schema.version="${IMAGE_VER}"


