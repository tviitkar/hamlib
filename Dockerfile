FROM alpine:3.24 AS build

ARG HAMLIB_VERSION=4.7.2

#hadolint ignore=DL3018
RUN apk add --no-cache build-base curl libusb-dev linux-headers

WORKDIR /src

RUN curl -fsSLO "https://github.com/Hamlib/Hamlib/releases/download/${HAMLIB_VERSION}/hamlib-${HAMLIB_VERSION}.tar.gz" && \
    curl -fsSLO "https://github.com/Hamlib/Hamlib/releases/download/${HAMLIB_VERSION}/SHA256SUM-${HAMLIB_VERSION}" && \
    sha256sum -c "SHA256SUM-${HAMLIB_VERSION}" && \
    tar xzf "hamlib-${HAMLIB_VERSION}.tar.gz"

WORKDIR /src/hamlib-${HAMLIB_VERSION}

# musl defines mode_t, which clashes with the harris backend prototype
RUN sed -i 's/vfo_t vfo, mode_t mode/vfo_t vfo, rmode_t mode/' rigs/harris/harris.h && \
    ./configure \
        --prefix=/usr/local \
        --disable-static \
        --disable-html-matrix \
        --without-readline \
        --without-cxx-binding \
        --without-indi \
        --without-xml-support && \
    make -j"$(nproc)" && \
    make install-strip DESTDIR=/out && \
    rm -rf /out/usr/local/include /out/usr/local/lib/pkgconfig \
        /out/usr/local/share/aclocal /out/usr/local/share/man && \
    find /out -name '*.la' -delete

FROM alpine:3.24

LABEL org.opencontainers.image.title="hamlib"
LABEL org.opencontainers.image.description="Containerized Hamlib suite"
LABEL org.opencontainers.image.source="https://github.com/tviitkar/hamlib"
LABEL org.opencontainers.image.licenses="MIT"

#hadolint ignore=DL3018
RUN adduser -D -G dialout -u 1000 ham && \
    apk add --no-cache libusb

COPY --from=build /out/usr/local /usr/local

USER 1000
WORKDIR /home/ham

CMD ["sh"]
