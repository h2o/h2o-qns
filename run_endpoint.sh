#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

ROLE=$1
shift

cd quicly

if [ "$ROLE" == "client" ]; then
    ./cli -p /100000000.txt server 4434 > /dev/null
elif [ "$ROLE" == "server" ]; then
    ./cli -k server.key -c server.crt -e srv.out 0.0.0.0 4434
fi