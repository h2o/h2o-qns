#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

# create tmpfs mount point for bpftrace to work
mkdir -p /build
mount -t tmpfs tmpfs build
chmod 0755 build

cp -R /quicly /build
cd /build/quicly

if [ "$ROLE" == "client" ]; then
    sleep 10
    echo "Starting quicly client ..."
    echo "CLIENT_PARAMS:" $CLIENT_PARAMS
    ./cli $CLIENT_PARAMS server 4434
elif [ "$ROLE" == "server" ]; then
    echo "Starting quicly server ..."
    echo "SERVER_PARAMS:" $SERVER_PARAMS
    ./cli $SERVER_PARAMS -k server.key -c server.crt 0.0.0.0 4434
# -e /qnslogs/quicly-srv.out
#    bpftrace -p `pidof cli` trace.d
fi
