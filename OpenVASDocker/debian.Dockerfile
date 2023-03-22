# syntax=docker/dockerfile:1.4
FROM debian:11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

COPY build.sh /build.sh
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/redis-openvas.conf /etc/redis.conf

RUN bash /build.sh

ENV gvm_libs_version="v22.4.4" \
    openvas_scanner_version="v22.4.1" \
    openvas_smb="v22.4.0" \
    open_scanner_protocol_daemon="v22.4.1" \
    ospd_openvas="v22.4.6" \
    notus_scanner="v22.4.4"

RUN echo "Starting Build..." && mkdir /build

    #
    # install libraries module for the Greenbone Vulnerability Management Solution
    #
    
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/gvm-libs/archive/$gvm_libs_version.tar.gz && \
    tar -zxf $gvm_libs_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *

    #
    # install smb module for the OpenVAS Scanner
    #
    
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/openvas-smb/archive/$openvas_smb.tar.gz && \
    tar -zxf $openvas_smb.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
    
    #
    # Install Open Vulnerability Assessment System (OpenVAS) Scanner of the Greenbone Vulnerability Management (GVM) Solution
    #
    
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/openvas-scanner/archive/$openvas_scanner_version.tar.gz && \
    tar -zxf $openvas_scanner_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
    
    #
    # Install Open Scanner Protocol daemon (OSPd)
    #
    
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/ospd/archive/$open_scanner_protocol_daemon.tar.gz && \
    tar -zxf $open_scanner_protocol_daemon.tar.gz && \
    cd /build/*/ && \
    python3 setup.py install && \
    cd /build && \
    rm -rf *
    
    #
    # Install Open Scanner Protocol for OpenVAS
    #
            
RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/ospd-openvas/archive/$ospd_openvas.tar.gz && \
    tar -zxf $ospd_openvas.tar.gz && \
    cd /build/*/ && \
    python3 setup.py install && \
    cd /build && \
    rm -rf *
    
    #
    # Install Notus Scanner
    #
    RUN cd /build && \
    wget --no-verbose https://github.com/greenbone/notus-scanner/archive/refs/tags/$notus_scanner.tar.gz && \
    tar -zxf notus_scanner.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd /build && \
    rm -rf *
    
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/openvas.conf && ldconfig && cd / && rm -rf /build

COPY scripts/* /

ENTRYPOINT ["/start.sh"]
