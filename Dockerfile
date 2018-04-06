FROM alpine:3.7

ADD https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 /usr/local/bin/jq
ADD assets/ /opt/resource/

RUN apk add --update curl git \
    && chmod +x /usr/local/bin/jq \
    && chmod +x /opt/resource/* \
    && PATH=/usr/local/bin:$PATH
