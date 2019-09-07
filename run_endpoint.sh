#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

cd quicly

if [ "$ROLE" == "client" ]; then
    sleep 10
    echo "Starting quicly client ..."
    echo "CLIENT_PARAMS:" $CLIENT_PARAMS
    ./cli $CLIENT_PARAMS -e /qnslogs/quicly-cli.out server 4434
elif [ "$ROLE" == "server" ]; then
    echo "Starting quicly server ..."
    echo "SERVER_PARAMS:" $SERVER_PARAMS
    ./cli $SERVER_PARAMS -e /qnslogs/quicly-srv.out -k server.key -c server.crt 0.0.0.0 4434
fi
