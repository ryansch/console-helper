FROM alpine:latest
LABEL maintainer="Ryan Schlesinger <ryan@ryanschlesinger.com>"

RUN set -eux; \
      \
      apk add --no-cache bash 

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
      \
      apk add --no-cache \
        curl \
        ca-certificates \
        tini \
        jq \
        docker-cli \
        py-pip \
        ncurses \
      ; \
      \
      pip install awscli; \
      aws --version

COPY helper.sh /usr/local/bin/
CMD ["/usr/local/bin/helper.sh"]
