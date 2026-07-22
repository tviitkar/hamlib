# rigctld

## Overview

`rigctld` is a radio control daemon from the Hamlib project that enables
control of a transceiver over TCP. It allows multiple client applications
(such as WSJT-X, FLrig, gpredict, Log4OM, N1MM) to share access to a single
radio device over network socket port `4532`.

This containerized version packages `rigctld` on Alpine Linux for easy,
non-root deployment.

---

## Example Usage (Docker Compose)

```yaml
services:
  rigctld:
    image: ghcr.io/tviitkar/rigctld:latest
    container_name: rigctld
    ports:
      - "4532:4532"
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0
    group_add:
      - dialout
    command: ["-m", "1042", "-r", "/dev/ttyUSB0", "-s", "38400"]
    restart: unless-stopped
    read_only: true
```

---

## Example Usage (Docker CLI)

```bash
docker run -d \
  --name rigctld \
  -p 4532:4532 \
  --device /dev/ttyUSB0:/dev/ttyUSB0 \
  --group-add dialout \
  --read-only \
  --restart unless-stopped \
  ghcr.io/tviitkar/rigctld:latest \
  -m 1042 -r /dev/ttyUSB0 -s 38400
```

---

## Serial Device Permissions & Host GID

The container runs as a non-root user (`ham`, UID 1000) belonging to Alpine's
`dialout` group.

On some host operating systems (like Arch Linux, Fedora, or custom distros),
the physical serial device node (e.g., `/dev/ttyUSB0` or `/dev/ttyACM0`) may
belong to a group with a different Group ID (GID).

- **Docker CLI**: Pass `--group-add dialout` or `--group-add <gid>` (e.g.,
  `--group-add 987`).
- **Docker Compose**: Add `group_add: ["dialout"]` or specify the numeric host
  serial GID `group_add: ["987"]`.

---

## Command Flags & Parameters

- `-m <model>`: Hamlib radio model number (e.g., `1042` for Yaesu FT-891, `3081`
  for Icom IC-7300, `2` for NET rigctl).
- `-r <device>`: Path to serial device node (e.g., `/dev/ttyUSB0`,
  `/dev/ttyACM0`).
- `-s <baud>`: Serial port speed / baud rate (e.g., `38400`, `115200`).

---

## Container Healthcheck

The image includes a built-in healthcheck:

```sh
rigctl -m 2 -r 127.0.0.1:4532 f
```

It queries the `rigctld` daemon over loopback to verify that the daemon is
listening and that the connected transceiver responds to frequency queries.

---

## References

- [Hamlib](https://github.com/Hamlib/Hamlib)
- [Hamlib supported radios](https://github.com/Hamlib/Hamlib/wiki/Supported-Radios)
- [Rigctld manual](https://www.mankier.com/1/rigctld)

---

## License

The Docker build scripts and documentation in this repository are licensed under the [MIT License](LICENSE).

Hamlib binaries packaged inside the container image are subject to their respective upstream licenses ([GPL-2.0](https://github.com/Hamlib/Hamlib/blob/master/COPYING) and [LGPL-2.1](https://github.com/Hamlib/Hamlib/blob/master/COPYING.LIB)).
