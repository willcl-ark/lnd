#!/usr/bin/env bash

set -ev

BITCOIND_VERSION=$1

if [ -z "$BITCOIND_VERSION" ]; then
  echo "Must specify a version of bitcoind to install."
  echo "Usage: install_bitcoind.sh <version>"
  exit 1
fi

# Set the target platform
TARGETPLATFORM=$(uname -m)
if [ "$TARGETPLATFORM" = "x86_64" ]; then
  export TARGETPLATFORM="x86_64-linux-gnu"
elif [ "$TARGETPLATFORM" = "arm64" ]; then
  export TARGETPLATFORM="arm64-apple-darwin"
else
  echo "Unsupported platform: $TARGETPLATFORM"
  exit 1
fi

# Define cache path.
# This must exactly match that used in main.yml workflow.
CACHE_DIR="bitcoind-${BITCOIND_VERSION}"

# Check if bitcoind is already cached
if [ -d "$CACHE_DIR" ]; then
  echo "Using cached bitcoind version ${BITCOIND_VERSION} for ${TARGETPLATFORM}"
  sudo cp "$CACHE_DIR"/bin/* /usr/local/bin/
  exit 0
fi

# Download and extract bitcoind
if [[ $BITCOIND_VERSION == *rc* ]]; then
  RC=$(echo "$BITCOIND_VERSION" | sed -E 's/.*(rc[0-9]+).*/\1/')
  BITCOIND_VERSION_STRIPPED=${BITCOIND_VERSION%rc*}
  URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIND_VERSION_STRIPPED}/test.${RC}/bitcoin-${BITCOIND_VERSION}-${TARGETPLATFORM}.tar.gz"
else
  URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIND_VERSION}/bitcoin-${BITCOIND_VERSION}-${TARGETPLATFORM}.tar.gz"
fi

wget "$URL"
tar zxvf "bitcoin-${BITCOIND_VERSION}-${TARGETPLATFORM}.tar.gz"

# Move the binary to cache directory
mkdir -p "$CACHE_DIR"
cp -r "bitcoin-${BITCOIND_VERSION}"/* "$CACHE_DIR"/

# Move the binary to the appropriate location
sudo cp "$CACHE_DIR"/bin/* /usr/local/bin/
