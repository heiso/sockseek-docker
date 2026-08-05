# sockseek-docker

[sockseek](https://github.com/fiso64/sockseek) ships release tarballs but no
container image. This packages them into one.

No fork, no vendored source, no compile — the image installs upstream's prebuilt
`linux-x64` release, so builds take seconds.

```
heiso/sockseek:latest
heiso/sockseek:<upstream-version>
```

`sockseek` is the entrypoint, so arguments go straight to it:

```sh
docker run --rm heiso/sockseek:latest --help
```

```yaml
services:
  sockseek:
    image: heiso/sockseek:latest
    user: "1000:1000"
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    command: >
      --user myuser --pass mypass
      -o /downloads
```

## Why not upstream's Dockerfile

Upstream's `Dockerfile` installs `dotnet6-sdk` while the code has targeted
`net10.0` since 2026-03-31, so it fails with `NETSDK1045` on any build today. It
was contributed in 2024 by a third party and no upstream workflow ever runs it,
so the breakage went unnoticed. Rather than compile, this installs the release
binary upstream already publishes.

Other differences from upstream's Dockerfile:

- **Debian, not Alpine.** The release binary is glibc-linked and will not run on
  musl. `libicu72` is required; .NET hard-fails at startup without it.
- **No LinuxServer base, no s6, no `DOCKER_MODS`.** Upstream's image pulls a cron
  mod from lscr.io at every container start. Use your scheduler of choice
  instead, and compose's `user:` in place of PUID/PGID.

`linux/amd64` only — upstream publishes no `linux-arm64` release asset.

## Setup

One-time, before the first run:

1. Create a **public** repository named `sockseek` on Docker Hub.
2. Create an access token with *Read & Write* scope
   (Docker Hub → Account settings → Personal access tokens).
3. In this repo → Settings → Secrets and variables → Actions:
   - variable `DOCKERHUB_USERNAME`
   - secret `DOCKERHUB_TOKEN`

## Rebuilding

Push to `main`, or run the workflow from the Actions tab. Each run picks up
upstream's latest release automatically.
