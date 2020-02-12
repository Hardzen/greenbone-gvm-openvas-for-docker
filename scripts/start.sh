#!/usr/bin/env bash
set -Eeuo pipefail

USERNAME=${USERNAME:-admin}
PASSWORD=${PASSWORD:-admin}

if [ ! -d "/run/redis" ]; then
	mkdir /run/redis
fi
if  [ -S /run/redis/redis.sock ]; then
        rm /run/redis/redis.sock
fi
redis-server --unixsocket /run/redis/redis.sock --unixsocketperm 700 --timeout 0 --databases 128 --maxclients 512 --daemonize yes --port 6379 --bind 0.0.0.0

echo "Wait for redis socket to be created..."
while  [ ! -S /run/redis/redis.sock ]; do
        sleep 1
done

echo "Testing redis status..."
X="$(redis-cli -s /run/redis/redis.sock ping)"
while  [ "${X}" != "PONG" ]; do
        echo "Redis not yet ready..."
        sleep 1
        X="$(redis-cli -s /run/redis/redis.sock ping)"
done
echo "Redis ready."

echo "Starting PostgreSQL..."
/usr/bin/pg_ctlcluster --skip-systemctl-redirect 10 main start

if [ ! -f "/firstrun" ]; then
  echo "Running first start configuration..."
  
  echo "Creating Openvas NVT sync user"
  useradd --home-dir /usr/local/share/openvas openvas-sync
  chown openvas-sync:openvas-sync -R /usr/local/share/openvas
  chown openvas-sync:openvas-sync -R /usr/local/var/lib/openvas
  
  echo "Creating Greenbone Vulnerability system user"
  useradd --home-dir /usr/local/share/gvm gvm
  chown gvm:gvm -R /usr/local/share/gvm
  mkdir /usr/local/var/lib/gvm/cert-data
  chown gvm:gvm -R /usr/local/var/lib/gvm
  chmod 770 -R /usr/local/var/lib/gvm
  chown gvm:gvm -R /usr/local/var/log/gvm
  chown gvm:gvm -R /usr/local/var/run
  
  echo "Creating Greenbone Vulnerability Manager database"
  su -c "createuser -DRS gvm" postgres
  su -c "createdb -O gvm gvmd" postgres
  su -c "psql --dbname=gvmd --command='create role dba with superuser noinherit;'" postgres
  su -c "psql --dbname=gvmd --command='grant dba to gvm;'" postgres
  su -c "psql --dbname=gvmd --command='create extension \"uuid-ossp\";'" postgres
  
  adduser openvas-sync gvm
  adduser gvm openvas-sync
  touch /firstrun
fi

echo "Updating NVTs..."
su -c "rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --progress rsync://feed.openvas.org:/nvt-feed /usr/local/var/lib/openvas/plugins" openvas-sync
sleep 5

echo "Updating CERT data..."
su -c "/cert-data-sync.sh" openvas-sync
sleep 5

echo "Updating SCAP data..."
su -c "/scap-data-sync.sh" openvas-sync

if [ -f /var/run/ospd.pid ]; then
  rm /var/run/ospd.pid
fi

if [ -S /tmp/ospd.sock ]; then
  rm /tmp/ospd.sock
fi

echo "Starting Open Scanner Protocol daemon for OpenVAS..."
ospd-openvas --log-file /usr/local/var/log/gvm/ospd-openvas.log --unix-socket /tmp/ospd.sock --log-level INFO

while  [ ! -S /tmp/ospd.sock ]; do
	sleep 1
done

chmod 666 /tmp/ospd.sock

echo "Starting Greenbone Vulnerability Manager..."
su -c "gvmd" gvm

until su -c "gvmd --get-users" gvm; do
	sleep 1
done

if [ ! -f "/set_max_rows_per_page" ]; then
	echo "Setting \"Max Rows Per Page\" to remove report size limit"
	su -c "gvmd --modify-setting 76374a7a-0569-11e6-b6da-28d24461215b --value 0" gvm
	
	touch /set_max_rows_per_page
fi

if [ ! -f "/created_gvm_user" ]; then
	echo "Creating Greenbone Vulnerability Manager admin user"
	su -c "gvmd --create-user=${USERNAME} --password=${PASSWORD}" gvm
	
	touch /created_gvm_user
fi

echo "Starting Greenbone Security Assistant..."
su -c "gsad --verbose --http-only --no-redirect --port=9392" gvm

echo "++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Your GVM 11 container is now ready to use! +"
echo "++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "++++++++++++++++"
echo "+ Tailing logs +"
echo "++++++++++++++++"
tail -F /usr/local/var/log/gvm/*