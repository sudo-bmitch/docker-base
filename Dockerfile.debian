ARG DEBIAN_VER=9
ARG REGISTRY=docker.io
FROM ${REGISTRY}/debian:${DEBIAN_VER}

# Include apt-install
COPY bin.debian/ /usr/bin/

RUN apt-install \
      ca-certificates \
      curl \
      rsync

# Install wait-for-it.sh
RUN curl -sSL https://github.com/vishnubob/wait-for-it/raw/master/wait-for-it.sh >/usr/bin/wait-for-it.sh \
 && chmod 755 /usr/bin/wait-for-it.sh

# Install tini
ARG TINI_VERSION=v0.16.1
RUN curl -sSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini >/usr/bin/tini \
 && chmod 755 /usr/bin/tini

# Install gosu
ARG GOSU_VERSION=1.10
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && curl -sSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}" >/usr/bin/gosu \
 && chmod 755 /usr/bin/gosu \
 && gosu nobody true

# Include various scripts (entrypointd.sh, healthcheckd.sh, fix-perms)
COPY bin/ /usr/bin/
COPY healthcheck.d/ /etc/healthcheck.d/
COPY entrypoint.d/ /etc/entrypoint.d/

HEALTHCHECK CMD /usr/bin/healthcheckd.sh
ENTRYPOINT ["/usr/bin/entrypointd.sh"]

CMD ["/bin/bash"]

ARG IMAGE_VERSION=1.0.0
ARG BASE_REPOSITORY=sudobmitch/base
LABEL \
    org.label-schema.docker.cmd="docker run -it --rm ${REGISTRY}/${BASE_REPOSITORY}:debian" \
    org.label-schema.description="Base image for debian" \
    org.label-schema.name="${REGISTRY}/${BASE_REPOSITORY}:debian" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/sudo-bmitch/docker-images" \
    org.label-schema.vendor="Brandon Mitchell" \
    org.label-schema.version="${IMAGE_VER}"


