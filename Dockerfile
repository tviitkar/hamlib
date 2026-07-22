FROM alpine:3.24

LABEL org.opencontainers.image.title="hamlib"
LABEL org.opencontainers.image.description="Containerized Hamlib suite"
LABEL org.opencontainers.image.source="https://github.com/tviitkar/hamlib"
LABEL org.opencontainers.image.licenses="MIT"

#hadolint ignore=DL3018
RUN adduser -D -G dialout -u 1000 ham && \
    apk add --no-cache hamlib

USER ham
WORKDIR /home/ham

CMD ["sh"]
