FROM alpine:latest

RUN adduser -D -G dialout -u 1000 ham && \
    apk update && \
    apk add --no-cache hamlib && \
    rm -rf /var/cache/apk/*

USER ham
WORKDIR /home/ham

ENTRYPOINT ["rigctld"]
