FROM alpine:latest

RUN adduser -D -G dialout -u 1000 ham && \
    apk update && \
    apk add --no-cache hamlib && \
    rm -rf /var/cache/apk/*

USER ham
WORKDIR /home/ham

HEALTHCHECK --interval=15s --timeout=30s --start-period=15s --retries=3 \
    CMD sh -c "rigctl -m 2 -r 127.0.0.1:4532 f >/dev/null 2>&1 || exit 1"

ENTRYPOINT ["rigctld"]
