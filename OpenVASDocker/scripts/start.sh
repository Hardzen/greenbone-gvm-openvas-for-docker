#!/usr/bin/env bash
set -Eeuo pipefail
export SUPVISD=${SUPVISD:-supervisorctl}
export SCANNER_ID
SCANNER_ID=$(cat /var/lib/gvm/.scannerid)
MASTER_PORT=${MASTER_PORT:-22}
DEBUG=${DEBUG:-NO}

if [ -z "${MASTER_ADDRESS}" ]; then
	echo "ERROR: The environment variable \"MASTER_ADDRESS\" is not set"
	exit 1
fi

if [ ! -d /var/lib/gvm/.ssh ]; then
	mkdir -p /var/lib/gvm/.ssh
fi

if [ ! -f /var/lib/gvm/.ssh/known_hosts ]; then
	echo "Getting Master SSH key..."
	ssh-keyscan -t ed25519 -p "${MASTER_PORT}" "${MASTER_ADDRESS}" >/var/lib/gvm/.ssh/known_hosts.temp
	mv /var/lib/gvm/.ssh/known_hosts.temp /var/lib/gvm/.ssh/known_hosts
fi

if [ ! -f /var/lib/gvm/.ssh/key ]; then
	echo "Setup SSH key..."
	ssh-keygen -t ed25519 -f /var/lib/gvm/.ssh/key -N "" -C "$(cat /var/lib/gvm/.scannerid)"
fi

## Start Redis

if [ ! -d "/run/redis" ]; then
	mkdir -p /run/redis
fi

if [ -S /run/redis/redis.sock ]; then
	rm /run/redis/redis.sock
fi


if [ -S /run/redis/redis.sock ]; then
	rm /run/redis/redis.sock
fi

mkdir -p /var/lib/notus
mkdir -p /run/notus-scanner/

chown gvm:gvm /var/lib/notus
chown gvm:gvm /run/notus-scanner/
chown mosquitto:mosquitto /run/mosquitto

if  ! grep -qis  allow_anonymous /etc/mosquitto/mosquitto.conf; then  
        echo -e "listener 1883\nallow_anonymous true" >> /etc/mosquitto/mosquitto.conf
fi
if  ! grep -qis  mosquitto /etc/openvas/openvas.conf; then  
	echo "mqtt_server_uri = localhost:1883" |  tee -a /etc/openvas/openvas.conf
fi

${SUPVISD} start redis
${SUPVISD} status redis

echo "Wait for redis socket to be created..."
while [ ! -S /run/redis/redis.sock ]; do
	sleep 1
done

echo "Testing redis status..."
X="$(redis-cli -s /run/redis/redis.sock ping)"
while [ "${X}" != "PONG" ]; do
	echo "Redis not yet ready..."
	sleep 1
	X="$(redis-cli -s /run/redis/redis.sock ping)"
done
echo "Redis ready."

echo "+++++++++++++++++++++++++++++++++++"
echo "+ Enabling Automating NVT updates +"
echo "+++++++++++++++++++++++++++++++++++"
${SUPVISD} start GVMUpdate
if [ "x${DEBUG}" == "xYES" ]; then
	${SUPVISD} status GVMUpdate
fi
sleep 5

#############################
# Remove leftover pid files #
#############################

if [ -f /var/run/ospd.pid ]; then
	rm /var/run/ospd.pid
fi

if [ -S /tmp/ospd.sock ]; then
	rm /tmp/ospd.sock
fi

if [ -S /var/run/ospd/ospd.sock ]; then
	rm /var/run/ospd/ospd.sock
fi

if [ ! -d /var/run/ospd ]; then
	mkdir -p /var/run/ospd
fi
echo "Starting Mosquitto daemon for OpenVAS..."
${SUPVISD} start mosquitto
if [[ "${DEBUG}" =~ ^(yes|y|YES|Y|true|TRUE)$ ]]; then
	${SUPVISD} status mosquitto
fi

echo "Starting Open Scanner Protocol daemon for OpenVAS..."
${SUPVISD} start ospd-openvas
if [ "x${DEBUG}" == "xYES" ]; then
	${SUPVISD} status ospd-openvas
fi

while [ ! -S /var/run/ospd/ospd.sock ]; do
	sleep 1
done
##Todo move to supervisord
notus-scanner --products-directory /var/lib/notus/products --log-file /var/log/gvm/notus-scanner.log &
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Your OpenVAS Scanner container is now ready to use! +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "-------------------------------------------------------"
echo "Scanner id: $(cat /var/lib/gvm/.scannerid)"
echo "Public key: $(cat /var/lib/gvm/.ssh/key.pub)"
echo "Master host key (Check that it matches the public key from the master):"
cat /var/lib/gvm/.ssh/known_hosts
echo "-------------------------------------------------------"
echo "If you start the firsttime, you should now add the scanner"
echo "to the gvmd container, via the /add/scanner.sh"
echo "After it, you need to restart this container!"
echo "-------------------------------------------------------"
touch /var/lib/gvm/.firststart
if [ -f /var/lib/gvm/.secondstart ]; then
	${SUPVISD} start autossh
	if [ "x${DEBUG}" == "xYES" ]; then
		${SUPVISD} status autossh
	fi
fi

echo "++++++++++++++++"
echo "+ Tailing logs +"
echo "++++++++++++++++"
tail -F /var/log/gvm/*
