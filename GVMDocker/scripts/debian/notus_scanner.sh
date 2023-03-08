#!/usr/bin/env bash
set -Eeuo pipefail
export INSTALL_PREFIX=/usr

export SOURCE_DIR=$HOME/source
mkdir -p "${SOURCE_DIR}"

export BUILD_DIR=$HOME/build
mkdir -p "${BUILD_DIR}"

export INSTALL_DIR=$HOME/install
mkdir -p "${INSTALL_DIR}"

curl -sSL https://github.com/greenbone/notus-scanner/archive/refs/tags/v${NOTUS_SCANNER_VERSION}.tar.gz -o ${SOURCE_DIR}/notus-scanner-${NOTUS_SCANNER_VERSION}.tar.gz
tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/notus-scanner-${NOTUS_SCANNER_VERSION}.tar.gz
cd ${SOURCE_DIR}/notus-scanner-${NOTUS_SCANNER_VERSION}
ls -l
mkdir -p $INSTALL_DIR/notus-scanner
python3 -m pip install --prefix=$INSTALL_PREFIX --root=$INSTALL_DIR/notus-scanner --no-warn-script-location .
sudo cp -rv $INSTALL_DIR/notus-scanner/* /
