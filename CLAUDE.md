# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single-Dockerfile project that builds [Hamlib](https://github.com/Hamlib/Hamlib) from the upstream release tarball and packages its daemons and utilities (`rigctld`, `rotctld`, `ampctld`, `rigctl`, `rotctl`, `ampctl`, …) into a non-root Alpine image published as `ghcr.io/tviitkar/hamlib`. There is no application code: the Dockerfile and the GitHub Actions workflows are the product.

## Commands

```sh
# Build locally (native arch, ~1 min)
docker build -t hamlib .

# Smoke test: packaged Hamlib version
docker run --rm hamlib rigctld -V

# Run a dummy rig daemon and query it (same check as the README healthcheck)
docker run -d --name rigctld --read-only hamlib rigctld -m 1
docker exec rigctld rigctl -m 2 -r 127.0.0.1:4532 f

# Lint (CI runs hadolint on Dockerfile changes)
docker run --rm -i hadolint/hadolint < Dockerfile
docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint:latest
```

## Image design

- `ARG HAMLIB_VERSION` in the Dockerfile is the single source of truth for the Hamlib version; CI reads it with `sed`, so keep the `ARG HAMLIB_VERSION=X.Y.Z` line format.
- Build stage verifies the tarball against upstream's `SHA256SUM-<version>`, then configures `--without-readline --without-cxx-binding --without-indi --without-xml-support` (deliberate: keeps `libusb` as the only runtime dependency).
- A `sed` fixes a `mode_t`/`rmode_t` prototype in `rigs/harris/harris.h` that fails on musl (same fix as Alpine's aports patch); it is a no-op once upstream fixes it.
- Final stage copies `/usr/local` from the build stage; runs as UID 1000 (`ham`, `dialout` group) so serial devices can be passed through; must work with `--read-only`. `CMD ["sh"]` — users supply the daemon as the command.
- OCI metadata lives in three places that must stay in sync: Dockerfile `LABEL`s, the `annotations` of the build step in `docker-publish.yml`, and the `labels` override of `docker/metadata-action` (needed because the action otherwise fills `description` and `licenses` from the GitHub repo settings). The image license is `MIT AND GPL-2.0-or-later AND GPL-3.0-or-later AND LGPL-2.1-or-later` (repo files and bundled cJSON MIT, Hamlib programs GPL-2.0+, `libhamlib` LGPL-2.1+ but it also links GPL-2.0+ `security/aes.c`/`sha256.c` and GPL-3.0+ `lib/precise_time.c`). Re-check bundled files' licenses when bumping Hamlib.

## CI/CD (`.github/workflows/`)

- **docker-publish.yml** — no schedule. Runs on manual dispatch or push to `main` touching the Dockerfile/workflow. Builds `linux/amd64`, `linux/arm64`, `linux/arm/v7` (the ARM platforms compile under QEMU; a full build takes ~40 min).
  - On `main`: pushes `<version>` + `latest`, then deletes `<version>-devel`.
  - On any other branch (manual dispatch): pushes `<version>-devel` only.
- **lint-dockerfile.yml** — hadolint on push/PR touching `Dockerfile`.
- **cleanup-ghcr.yml** — nightly deletion of untagged GHCR images (left over from overwritten tags).

Release flow for a new Hamlib version (maintainer-only, intentionally not in the README): feature branch → bump `HAMLIB_VERSION` → `gh workflow run docker-publish.yml --ref <branch>` → test `<version>-devel` → merge to `main`.

## Conventions

- Conventional-commit style messages (`feat:`, `ci:`, `docs:`, `refactor:`, …).
- Issue-numbered branches (e.g. `18-build-hamlib-from-upstream-source-instead-of-alpine-package`) merged to `main` via PR.
