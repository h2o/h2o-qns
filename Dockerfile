FROM kazuho/h2o-ci:ubuntu1904

USER root
WORKDIR /

RUN apt-get update && \
  apt-get install -y net-tools iputils-ping tcpdump ethtool iperf

RUN cd /

# quicly
RUN git clone https://github.com/h2o/quicly.git
RUN cd quicly &&  git pull && git submodule update --init --recursive && cmake . && make
COPY server.key quicly
COPY server.crt quicly

# setup and endpoint
COPY setup.sh .
RUN sudo chmod +x setup.sh
COPY run_endpoint.sh .
RUN sudo chmod +x run_endpoint.sh
ENTRYPOINT [ "./run_endpoint.sh" ]
