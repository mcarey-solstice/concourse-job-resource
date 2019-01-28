###
# https://hub.docker.com/r/mcareysolstice/concourse-job-resource
##

FROM alpine:latest

RUN apk update && \
    apk add jq bash && \
    rm -rf /var/cache/apk/* /tmp/*

RUN wget -O /usr/local/bin/fly https://github.com/concourse/fly/releases/download/v4.2.2/fly_linux_amd64 && \
    chmod +x /usr/local/bin/fly

RUN mkdir -p /opt/resource

COPY ./assets/* /opt/resource/

# docker build -t mcareysolstice/concourse-job-resource .
