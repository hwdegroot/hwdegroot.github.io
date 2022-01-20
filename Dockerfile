FROM debian:latest

MAINTAINER Rik de Groot <hwdegroot@gmail.com>

ARG HUGO_VERSION
ARG PORT=1313
ENV HUGO_RELEASE=hugo_extended_${HUGO_VERSION}_Linux-64bit

RUN apt-get update && \
    apt-get install -yy \
        git \
        asciidoctor \
        libc6 \
        libstdc++6 \
        ca-certificates \
        curl \
        openssh-client

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src

RUN curl -sSLo ${HUGO_RELEASE}.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_RELEASE}.tar.gz
RUN curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_checksums.txt | \
        grep ${HUGO_RELEASE}.tar.gz > ${HUGO_RELEASE}.sha256
RUN cat ${HUGO_RELEASE}.sha256 | sha256sum -c
RUN tar -xzf ${HUGO_RELEASE}.tar.gz
RUN mv hugo /usr/local/bin/hugo
RUN rm -f ${HUGO_RELEASE}.*

VOLUME /src
VOLUME /publish

WORKDIR /src

EXPOSE ${PORT}
