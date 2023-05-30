FROM debian:bullseye-slim

ARG ROUTER_RELEASE=latest
ARG DEBUG_IMAGE=true

WORKDIR /dist

# Install curl
RUN \
  apt-get update -y \
  && apt-get install -y \
    curl

# If debug image, install heaptrack and make a data directory
RUN \
  if [ "${DEBUG_IMAGE}" = "true" ]; then \
    apt-get install -y heaptrack && \
    mkdir data; \
  fi

# Clean up apt lists
RUN rm -rf /var/lib/apt/lists/*

# Make directories for config and schema
RUN mkdir config schema

# Run the Router downloader which puts Router into current working directory
RUN curl -sSL https://router.apollo.dev/download/nix/${ROUTER_RELEASE}/ | sh

RUN curl -L https://supergraph.demo.starstuff.dev/ > schema/starstuff.graphql

# Copy configuration for docker image
COPY router.yaml config
COPY rhai rhai


ENV APOLLO_ROUTER_CONFIG_PATH="/dist/config/router.yaml"
ENV APOLLO_ROUTER_SUPERGRAPH_PATH="/dist/schema/starstuff.graphql"

# Create a wrapper script to run the router, use exec to ensure signals are handled correctly
RUN \
  echo '#!/usr/bin/env bash \
\nset -e \
\n \
\nif [ -f "/usr/bin/heaptrack" ]; then \
\n    exec heaptrack -o /dist/data/router_heaptrack /dist/router "$@" \
\nelse \
\n    exec /dist/router "$@" \
\nfi \
' > /dist/router_wrapper.sh

EXPOSE 4000

# Make sure we can run our wrapper
RUN chmod 755 /dist/router_wrapper.sh

# Default executable is the wrapper script
CMD ["/dist/router_wrapper.sh"]