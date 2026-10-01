# Hamlib

## Overview

`hamlib` provides containerized network control daemons and command-line
utilities from the [Hamlib](https://github.com/Hamlib/Hamlib) project on Alpine
Linux. Hamlib is built from the official upstream release tarball, so new
versions are available without waiting for distribution packages.

This container image packages the entire Hamlib software suite (`rigctld`,
`rotctld`, `ampctld`, `rigctl`, `rotctl`, etc.) into a lightweight, non-root
image (`ghcr.io/tviitkar/hamlib`).

- **`rigctld`**: Transceiver control daemon (default port `4532`).
- **`rotctld`**: Antenna rotator control daemon (default port `4533`).
- **`ampctld`**: Linear amplifier control daemon (default port `4531`).
- **`rigctl` / `rotctl` / `ampctl`**: Command-line control and testing utilities.

## Examples

### Docker Compose

```yaml
services:
  rigctld:
    image: ghcr.io/tviitkar/hamlib:latest
    container_name: rigctld
    command: rigctld -m 1
    ports:
      - "4532:4532"
    healthcheck:
      test:
        - CMD-SHELL
        - "rigctl -m 2 -r 127.0.0.1:4532 f 2>&1 | grep -q '^[0-9]' || exit 1"
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 20s
    restart: unless-stopped
    read_only: true
```

### Docker CLI

```bash
docker run -d \
  --name rigctld \
  -p 4532:4532 \
  --read-only \
  --restart unless-stopped \
  ghcr.io/tviitkar/hamlib:latest \
  rigctld -m 1
```

## Image Tags

- **`latest`**: Most recent release build.
- **`<version>`** (e.g. `4.7.2`): Release build of a specific Hamlib version.
- **`<version>-devel`**: Pre-release test build from a feature branch. Removed
  once the version is released.

Images are published for `linux/amd64`, `linux/arm64` and `linux/arm/v7`.

## Serial Device Permissions

The container runs as a non-root user (`ham`, UID 1000) belonging to Alpine's
`dialout` group.

On host operating systems where physical serial device nodes (e.g.,
`/dev/ttyUSB0` or `/dev/ttyACM0`) belong to a different Group ID (GID):

- **Docker CLI**: Pass `--device /dev/ttyUSB0:/dev/ttyUSB0 --group-add dialout`
  or `--group-add <gid>` (e.g., `--group-add 987`).
- **Docker Compose**: Add `devices: ["/dev/ttyUSB0:/dev/ttyUSB0"]` and
  `group_add: ["dialout"]` (or numeric host serial GID `group_add: ["987"]`).

## Healthchecks

Healthchecks should be configured in your `docker-compose.yml` or container
orchestrator based on the daemon being executed.

For example, testing a `rigctld` daemon on port 4532:

```sh
rigctl -m 2 -r 127.0.0.1:4532 f 2>&1 | grep -q '^[0-9]' || exit 1
```

## References

- [Hamlib](https://github.com/Hamlib/Hamlib)

## License

The Docker build scripts and documentation in this repository are licensed
under the [MIT License](LICENSE).

Hamlib binaries built inside the container image are subject to their
respective upstream licenses: the programs (`rigctld`, `rotctld`, etc.) are
[GPL-2.0-or-later](https://github.com/Hamlib/Hamlib/blob/master/COPYING), and
the `libhamlib` library is
[LGPL-2.1-or-later](https://github.com/Hamlib/Hamlib/blob/master/COPYING.LIB)
but also includes bundled code under GPL-2.0-or-later,
[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.html) and MIT.

### Source Code

Each image is built from the official Hamlib release tarball for its version
(`https://github.com/Hamlib/Hamlib/releases/download/<version>/hamlib-<version>.tar.gz`),
with one change applied by the [`Dockerfile`](Dockerfile): a type name fix in
`rigs/harris/harris.h` required to compile on Alpine's musl C library. Hamlib's
license files (GPL-2.0 and LGPL-2.1 texts) are included in the image under
`/usr/local/share/doc/hamlib`.
