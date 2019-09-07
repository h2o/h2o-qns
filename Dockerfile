FROM kazuho/h2o-ci:ubuntu1904

USER root
WORKDIR /

RUN apt-get update && \
  apt-get install -y net-tools iputils-ping tcpdump ethtool iperf

# quicly
RUN git clone https://github.com/h2o/quicly.git
RUN cd quicly &&  git submodule update --init --recursive && cmake . && make
#git checkout kazuho/usdt &&
COPY server.key quicly
COPY server.crt quicly

COPY setup.sh .
RUN sudo chmod +x setup.sh

# Copy endpoint driver and run it
COPY run_endpoint.sh .
RUN sudo chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
