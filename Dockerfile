FROM ubuntu:24.04 AS base

RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

FROM base AS builder

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update && \
  apt-get install -y --no-install-recommends curl ca-certificates build-essential pkg-config libssl-dev libevent-dev bison flex

WORKDIR /work

ARG NSD_VERSION=4.13.0

RUN curl -fsSL https://nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz | tar xz

RUN cd nsd-${NSD_VERSION} && \
  ./configure --disable-dnstap && \
  make -j$(nproc) && \
  make install DESTDIR=/nsd-build

FROM base

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update && \
  apt-get install -y --no-install-recommends libevent-2.1-7t64

RUN useradd --user-group --no-create-home nsd

# COPY --from=builder /nsd-build /
RUN --mount=type=bind,from=builder,source=/nsd-build,target=/nsd-build,rw \
  cd /nsd-build && \
  rm -r var/run tmp && \
  cp -a . /

RUN mkdir -p /var/nsd/chroot && \
  cd /var/nsd/chroot && \
  mkdir -p etc/nsd tmp var/db/nsd var/run && \
  chmod 1777 tmp && \
  chown -R nsd:nsd var/db/nsd

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
