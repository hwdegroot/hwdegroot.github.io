FROM registry.gitlab.com/pages/hugo:latest

MAINTAINER Rik de Groot <hwdegroot@gmail.com>

RUN apk add --update \
        bash \
        ca-certificates\
        curl \
        git \
        openssh-client

VOLUME /src
VOLUME /publish

WORKDIR /src

EXPOSE ${PORT}
