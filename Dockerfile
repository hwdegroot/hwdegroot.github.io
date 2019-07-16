FROM alpine:latest

MAINTAINER Rik de Groot <hwdegroot@gmail.com>

ARG HUGO_VERSION
ARG PORT=1313
ENV HUGO_RELEASE=hugo_extended_${HUGO_VERSION}_Linux-64bit

RUN echo ${HUGO_RELEASE}

RUN apk add --update \
        git \
        asciidoctor \
        libc6-compat \
        libstdc++ && \
\
    apk upgrade && \
\
    apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        openssh-client

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
\
    curl -sSLo ${HUGO_RELEASE}.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_RELEASE}.tar.gz && \
    curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_checksums.txt | \
        grep ${HUGO_RELEASE}.tar.gz > ${HUGO_RELEASE}.sha256 && \
    cat ${HUGO_RELEASE}.sha256 | sha256sum -c && \
    tar -xzf ${HUGO_RELEASE}.tar.gz && \
    mv hugo /usr/local/bin/hugo && \
    rm -f ${HUGO_RELEASE}.* && \
\
    curl -sSLo minify-stable.tar.gz https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz && \
    tar -xzf minify-stable.tar.gz && \
    mv minify /usr/local/bin/ && \
    rm -f minify-stable.tar.gz && \
\
    addgroup -Sg 1000 hugo && \
    adduser -SG hugo -u 1000 -h /tmp/hugo hugo

VOLUME /src
VOLUME /publish

WORKDIR /src

USER hugo

EXPOSE ${PORT}
