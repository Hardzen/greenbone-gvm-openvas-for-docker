#!/usr/bin/env bash
set -Eeo pipefail
if [[ ! "${AUTO_SYNC}" =~ ^(yes|y|YES|Y|true|TRUE)$ ]]; then
  exit 0
fi

exec_as_gvm(){
	# if root
	if [ "$EUID" -eq 0 ]; then
		su -c "$1" gvm
		return
	elif [ "$(whoami)" = "gvm" ]; then
		eval "$1"
		return
	else
		echo "Run this script either as root or as gvm user"
	fi

	false
}

if [ ! -f "/var/lib/gvm/.firstsync" ]; then

  mkdir -p /var/lib/gvm/data-objects/gvmd
  chown gvm:gvm /var/lib/gvm
  find /var/lib/gvm \( ! -user gvm -o ! -group gvm \)  -exec chown gvm:gvm {} +

  mkdir -p /var/lib/openvas/plugins
  chown gvm:gvm /var/lib/openvas
  find /var/lib/openvas \( ! -user gvm -o ! -group gvm \)  -exec chown gvm:gvm {} +

  mkdir -p /var/log/gvm
  chown gvm:gvm /var/log/gvm
  find /var/log/gvm \( ! -user gvm -o ! -group gvm \)  -exec chown gvm:gvm {} +

	find /var/lib/openvas/ -type d -exec chmod 755 {} +
	find /var/lib/gvm/ -type d -exec chmod 755 {} +
	find /var/lib/openvas/ -type f -exec chmod 644 {} +
	find /var/lib/gvm/ -type f -exec chmod 644 {} +
	find /var/lib/gvm/gvmd/report_formats -type f -name "generate" -exec chmod +x {} \;


fi

set +Eeuo pipefail
echo "Updating NVTs..."
echo "Update 22.4..."
exec_as_gvm "/usr/bin/greenbone-feed-sync"

sleep 5
true
