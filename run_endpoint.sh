#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

ROLE=$1
shift

cd quicly

if [ "$ROLE" == "client" ]; then
    echo "Starting quicly client ..."
    ./cli -p /10000000.txt -e /qnslogs/quicly-cli.out server 4434
elif [ "$ROLE" == "server" ]; then
    echo "Starting quicly server ..."
    ./cli -k server.key -c server.crt -e /qnslogs/quicly-srv.out 0.0.0.0 4434
fi
