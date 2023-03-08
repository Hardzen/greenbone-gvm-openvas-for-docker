#!/usr/bin/env bash
set -Eeuo pipefail

apt install libpopt-dev

curl -sSL https://github.com/greenbone/notus-scanner/archive/refs/tags/v${NOTUS_SCANNER_VERSION}.tar.gz -o ${SOURCE_DIR}/notus-scanner-${NOTUS_SCANNER_VERSION}.tar.gz
tar -C ${SOURCE_DIR} -xvzf ${SOURCE_DIR}/notus-scanner-${NOTUS_SCANNER_VERSION}.tar.gz
cd ${SOURCE_DIR}/notus-scanner-${NOTUS_SCANNER_VERSION}
ls -l
python3 -m pip install .
