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

# Check if the version contains rc*
if [[ $BITCOIND_VERSION == *rc* ]]; then
    RC=$(echo "$BITCOIND_VERSION" | sed -E 's/.*(rc[0-9]+).*/\1/')
    BITCOIND_VERSION_STRIPPED=${BITCOIND_VERSION%rc*}
    URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIND_VERSION_STRIPPED}/test.${RC}/bitcoin-${BITCOIND_VERSION}-${TARGETPLATFORM}.tar.gz"
else
    RC=""
    URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIND_VERSION}/bitcoin-${BITCOIND_VERSION}-${TARGETPLATFORM}.tar.gz"
fi

wget "$URL"
tar zxvf "bitcoin-${BITCOIND_VERSION}-${TARGETPLATFORM}.tar.gz"
sudo mv "bitcoin-${BITCOIND_VERSION}"/bin/* /usr/local/bin/
