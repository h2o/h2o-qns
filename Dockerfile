FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get --yes update

# tools for building and testing
RUN apt-get install --yes apache2-utils cmake cmake-data git memcached netcat-openbsd nghttp2-client redis-server wget sudo
RUN apt-get install --yes libev-dev libc-ares-dev libnghttp2-dev libssl-dev libuv1-dev zlib1g-dev

# curl with http2 support
RUN wget --no-verbose -O - https://curl.haxx.se/download/curl-7.57.0.tar.gz | tar xzf -
RUN (cd curl-7.57.0 && ./configure --prefix=/usr/local --with-nghttp2 --disable-shared && make && sudo make install)

# openssl 1.1.0
ARG OPENSSL_URL="https://www.openssl.org/source/"
ARG OPENSSL_VERSION="1.1.0i"
ARG OPENSSL_SHA1="6713f8b083e4c0b0e70fd090bf714169baf3717c"
RUN curl -O ${OPENSSL_URL}openssl-${OPENSSL_VERSION}.tar.gz
RUN (echo "${OPENSSL_SHA1} openssl-${OPENSSL_VERSION}.tar.gz" | sha1sum -c - && tar xf openssl-${OPENSSL_VERSION}.tar.gz)
RUN (cd openssl-${OPENSSL_VERSION} && \
    ./config --prefix=/opt/openssl-1.1.0 --openssldir=/opt/openssl-1.1.0 shared enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers && \
    make -j $(nproc) && make -j install_sw install_ssldirs)

# quicly
RUN git clone https://github.com/h2o/quicly.git
RUN cd quicly && git submodule update --init --recursive && cmake . && make
COPY server.key quicly
COPY server.crt quicly

# Copy endpoint driver and run it
COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ] 
