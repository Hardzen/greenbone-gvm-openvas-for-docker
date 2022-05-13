# syntax=docker/dockerfile:1.4
ARG CACHE_IMAGE=deineagenturug/gvm
ARG CACHE_BUILD_IMAGE=deineagenturug/gvm-build

ARG POSTGRESQL_VERSION="13"
ARG GSAD_VERSION="21.4.4"
ARG GSA_VERSION="21.4.4"
ARG GVM_LIBS_VERSION="21.4.4"
ARG GVMD_VERSION="21.4.5"
ARG OPENVAS_SCANNER_VERSION="21.4.4"
ARG OPENVAS_SMB_VERSION="21.4.0"
ARG PYTHON_GVM_VERSION="21.11.0"
ARG OSPD_OPENVAS_VERSION="21.4.4"
ARG GVM_TOOLS_VERSION="21.10.0"

ARG SUPVISD=supervisorctl
ARG GVMD_USER
ARG GVMD_PASSWORD
ARG USERNAME=admin
ARG PASSWORD=adminpassword
ARG PASSWORD_FILE=none
ARG TIMEOUT=15
ARG DEBUG=N
ARG RELAYHOST=smtp
ARG SMTPPORT=25
ARG AUTO_SYNC=YES
ARG AUTO_SYNC_ON_START=YES
ARG CERTIFICATE=none
ARG CERTIFICATE_KEY=none
ARG HTTPS=true
ARG TZ=Etc/UTC
ARG SSHD=false
ARG DB_PASSWORD=none

ARG INSTALL_PREFIX=/usr
ARG SOURCE_DIR=/source
ARG BUILD_DIR=/build
ARG INSTALL_DIR=/install
ARG DESTDIR=/install

FROM ${CACHE_BUILD_IMAGE}:build_gvm_libs AS build_gvm_libs

FROM ${CACHE_BUILD_IMAGE}:build_base AS build

ARG CACHE_IMAGE
ARG CACHE_BUILD_IMAGE
ARG INSTALL_PREFIX
ARG SOURCE_DIR
ARG BUILD_DIR
ARG INSTALL_DIR
ARG DESTDIR
ENV INSTALL_PREFIX=${INSTALL_PREFIX} \
    SOURCE_DIR=${SOURCE_DIR} \
    BUILD_DIR=${BUILD_DIR} \
    INSTALL_DIR=${INSTALL_DIR} \
    DESTDIR=${DESTDIR}

ARG GSAD_VERSION
ENV GSAD_VERSION=${GSAD_VERSION}
COPY --from=build_gvm_libs / /

RUN set -eu; \
    apt-get update; \
    apt install -y --no-install-recommends netcat; \
    cp /opt/context-full/helper/config/30detectproxy /etc/apt/apt.conf.d/30detectproxy; \
    cp /opt/context-full/helper/config/detect-http-proxy /etc/apt/detect-http-proxy; \
    chmod +x /etc/apt/detect-http-proxy; \
	mkdir -p /usr/local/share/keyrings/; \
	cp /opt/context-full/GVMDocker/build/postgres_ACCC4CF8.asc /usr/local/share/keyrings/postgres.gpg.asc; \
	cp /opt/context-full/GVMDocker/build/postgres_ACCC4CF8.gpg /etc/apt/trusted.gpg.d/postgres.gpg; \
	cp /opt/context-full/helper/config/apt-github.deineagentur.com.gpg.key /usr/local/share/keyrings/apt-github.deineagentur.com.gpg.asc; \
	cp /opt/context-full/helper/config/apt-github.deineagentur.com.gpg /etc/apt/trusted.gpg.d/apt-github.deineagentur.com.gpg; \
	cp /opt/context-full/helper/config/apt-sources.org.list /etc/apt/sources.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https;\
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/local/lib" >/etc/ld.so.conf.d/openvas.conf && ldconfig
RUN if [ ! -f "${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz" ]; then \
        curl -sSL "https://github.com/greenbone/gsad/archive/refs/tags/v${GSAD_VERSION}.tar.gz" -o "${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz" ; \
        curl -sSL "https://github.com/greenbone/gsad/releases/download/v${GSAD_VERSION}/gsad-${GSAD_VERSION}.tar.gz.asc" -o "${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz.asc" ; \
        gpg --verify "${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz.asc" "${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz" ; \
    fi
RUN tar -C "${SOURCE_DIR}" -xvzf "${SOURCE_DIR}/gsad-${GSAD_VERSION}.tar.gz" \
    && mkdir -p "${BUILD_DIR}/gsad" && cd $_ \
    && cmake "${SOURCE_DIR}/gsad-${GSAD_VERSION}" \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DLOGROTATE_DIR=/etc/logrotate.d \
    -DGVMD_RUN_DIR=/run/gvmd \
    -DGSAD_RUN_DIR=/run/gsad \
    -DGSAD_PID_DIR=/run/gsad \
    && make -j$(nproc) \
    && make DESTDIR=${INSTALL_DIR} install \
    && cp -R /install_gsa/. "${INSTALL_DIR}/"


FROM scratch
ARG INSTALL_DIR
COPY --from=build ${INSTALL_DIR}/ /
