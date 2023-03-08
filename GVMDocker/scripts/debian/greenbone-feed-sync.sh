#!/usr/bin/env bash
set -Eeuo pipefail
export INSTALL_PREFIX=/usr

export SOURCE_DIR=$HOME/source
mkdir -p "${SOURCE_DIR}"

export BUILD_DIR=$HOME/build
mkdir -p "${BUILD_DIR}"

export INSTALL_DIR=$HOME/install


mkdir -p "${INSTALL_DIR}"
mkdir -p $INSTALL_DIR/greenbone-feed-sync
python3 -m pip install --root=$INSTALL_DIR/greenbone-feed-sync --no-warn-script-location greenbone-feed-sync
sudo cp -rv $INSTALL_DIR/greenbone-feed-sync/* /
