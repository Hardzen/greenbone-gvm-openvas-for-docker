#!/usr/bin/env bash
# This script update the NVTs in the background every 12 hours.
set -Eeuo pipefail

if [ ! -f "/var/lib/gvm/.firstsync" ]; then
	echo "Downloading data TAR to speed up first sync..."
	mkdir -p /tmp/data

	echo "Extracting internal data TAR..."
	su gvm -c "/usr/local/bin/greenbone-nvt-sync"

	chown gvm:gvm -R /tmp/data
	cp -a /tmp/data/. /var/lib/openvas/plugins/
	chown gvm:gvm -R /var/lib/openvas

	find /var/lib/openvas/ -type d -exec chmod 755 {} +
	find /var/lib/openvas/ -type f -exec chmod 644 {} +

	set +e
	rm -r /tmp/data || true
	set -e
	touch /var/lib/gvm/.firstsync
fi

while true; do
	echo "Running Automatic NVT update..."
	su gvm -c "/usr/local/bin/greenbone-nvt-sync"
	sleep 43200
done
