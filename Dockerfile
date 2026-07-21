FROM alpine:3.20

RUN adduser -D -G dialout -u 1000 ham && \
    apk add --no-cache hamlib

USER ham
WORKDIR /home/ham

HEALTHCHECK --interval=15s --timeout=30s --start-period=15s --retries=3 \
    CMD sh -c "rigctl -m 2 -r 127.0.0.1:4532 f 2>&1 | grep -q '^[0-9]' || exit 1"

ENTRYPOINT ["rigctld"]
