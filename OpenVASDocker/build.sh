#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
echo "Acquire::http::Proxy \"${http_proxy}\";" >> /etc/apt/apt.conf.d/30proxy
echo "APT::Install-Recommends \"0\" ; APT::Install-Suggests \"0\" ;" >> /etc/apt/apt.conf.d/10no-recommend-installs
apt-get update -q
apt-get install -yq --no-install-recommends \
  apt-utils \
  coreutils \
  ca-certificates \
  gnupg \
  sudo \
  rsync \
  wget \
  lsb-release \
  curl
echo "/usr/local/lib" | tee /etc/ld.so.conf.d/openvas.conf
ldconfig
echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' | tee /etc/environment
sed -i '7c\ \ PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' /etc/profile

echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt-get update -q


{ cat <<EOF
autossh
bison
build-essential
ca-certificates
cmake
curl
dsniff
g++
gcc
gcc-mingw-w64
glib-2.0
gnupg-utils
gnutls-bin
gpg
heimdal-dev
heimdal-multidev
ike-scan
iputils-ping
ldap-utils
libbsd-dev
libgcrypt20-dev
libglib2.0-0
libglib2.0-dev
libgnutls28-dev
libgnutls30
libgpgme-dev
libgpgme11
libhiredis-dev
libhiredis0.14
libjson-glib-1.0-0
libjson-glib-dev
libksba-dev
libldap-2.4-2
libldap2-dev
libnet1
libnet1-dev
libp11-kit0
libpaho-mqtt-dev
libpaho-mqtt1.3
libpcap-dev
libpcap0.8/bullseye-backports
libpcre3
libpopt-dev
libradcli-dev
libradcli4
libsnmp-dev
libssh-gcrypt-4
libssh-gcrypt-dev
libunistring-dev
libuuid1
libxml2
libxml2-dev
mosquitto
net-tools
netdiag
nmap
openssh-client
perl-base
pkg-config
pnscan
python3
python3-cffi
python3-defusedxml
python3-deprecated
python3-gnupg
python3-impacket
python3-lxml
python3-packaging
python3-paho-mqtt
python3-paramiko
python3-pip
python3-psutil
python3-redis
python3-setuptools
python3-wrapt
redis
rsync
smbclient
snmp
supervisor
uuid-dev
wapiti
wget
xz-utils
EOF
} | xargs apt-get install -yq --no-install-recommends

{
  echo "/usr/local/lib";
  echo "/usr/lib";
} >/etc/ld.so.conf.d/openvas.conf
ldconfig

find / -name '*libopenvas_wmiclient*'

python3 -m pip install --upgrade ospd_openvas
python3 -m pip install --upgrade gvm-tools
python3 -m pip install --upgrade python-gvm


useradd -r -M -d /var/lib/gvm -U -G sudo -s /bin/bash gvm
usermod -aG tty gvm
usermod -aG sudo gvm
usermod -aG gvm redis
mkdir -p /run/redis
chown redis:gvm /run/redis
mkdir -p /run/gvmd
mkdir -p /var/lib/gvm
mkdir -p /var/log/gvm
mkdir -p /etc/openvas/
chgrp -R gvm /etc/openvas/
mkdir -p /var/lib/openvas/plugins
chown -R gvm:gvm /var/lib/openvas/
chown -R gvm:gvm /run/gvmd
chown -R gvm:gvm /var/lib/gvm
chown -R gvm:gvm /var/log/gvm



mkdir -p /opt/setup/scripts
#cp -a /opt/context/scripts/. /opt/setup/scripts/
#wget -O /opt/setup/nvt-feed.tar.xz https://vulndata.deineagentur.biz/nvt-feed.tar.xz

echo "gvm ALL = NOPASSWD: /usr/sbin/openvas" > /etc/sudoers.d/gvm
chmod 0440 /etc/sudoers.d/gvm

#cp /opt/context/config/supervisord.conf /etc/supervisord.conf
#cp /opt/context/config/redis-openvas.conf /etc/redis.conf
rm -rf /var/lib/apt/lists/*
