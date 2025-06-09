# rigctld

## Overview

rigctld is a radio control daemon from the Hamlib project that enables control of a transceiver over TCP. It allows multiple client applications to share access to a single radio device. This containerized version packages rigctld for easy deployment and integration.

## Example Usage (Docker Compose)

``` yaml
services:
  rigctld:
    image: tviitkar/rigctld:latest
    container_name: rigctld
    ports:
      - "4532:4532"
    devices:
      - /path/to/transceiver:/dev/ttyUSB0
    command: ["-m", "1042", "-r", "/dev/ttyUSB0"]
    restart: unless-stopped
    read_only: true
```

Replace `/path/to/transceiver` with the actual path to your rig device (e.g. /dev/ttyUSB0). Model `1042` is just an example — set it according to your transceiver. See the Hamlib rig list for valid model numbers.

## References

- [rigctld manual](https://www.mankier.com/1/rigctld)
- [Supported radios](https://github.com/Hamlib/Hamlib/wiki/Supported-Radios)
