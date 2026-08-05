# Upstream ships prebuilt release tarballs but no image, and its own Dockerfile
# is stale (installs dotnet6-sdk while the code targets net10.0). So install the
# release binary instead of compiling.
#
# The linux-x64 release is glibc-linked, so this is Debian-based, not Alpine.
FROM debian:bookworm-slim

ARG SOCKSEEK_VERSION=3.0.4

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libicu72; \
  curl -fsSL -o /tmp/sockseek.tar.gz \
    "https://github.com/fiso64/sockseek/releases/download/v${SOCKSEEK_VERSION}/sockseek_${SOCKSEEK_VERSION}_linux-x64.tar.gz"; \
  tar xzf /tmp/sockseek.tar.gz -C /usr/local/bin sockseek; \
  chmod +x /usr/local/bin/sockseek; \
  apt-get purge -y curl; \
  apt-get autoremove -y; \
  apt-get clean; \
  rm -rf /tmp/* /var/lib/apt/lists/*

WORKDIR /downloads

ENTRYPOINT ["sockseek"]
