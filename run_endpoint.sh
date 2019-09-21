#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh
cd quicly

if [ ! -z "$TESTCASE" ]; then
    case "$TESTCASE" in
        "transfer"|"retry") ;;
        "resumption") exit 127 ;;
        *) exit 127 ;;
    esac
fi

if [ "$ROLE" == "client" ]; then
    sleep 10
    cd /downloads
    case "$TESTCASE" in
        *) ;;
    esac
    echo "Starting quicly client ..."
    if [ ! -z "$REQUESTS" ]; then
        for REQ in $REQUESTS; do
            FILE=`echo $REQ | cut -f4 -d'/'`
            echo "/quicly/cli -p /$FILE -e /logs/$TESTCASE-$FILE.out server 443"
            /quicly/cli -p /$FILE -e /logs/$TESTCASE-$FILE.out server 4434 > $FILE
        done
    fi

elif [ "$ROLE" == "server" ]; then
    echo "Starting server for test:" $TESTCASE
    cd /www && ls -l
    case "$TESTCASE" in
        "retry") TEST_PARAMS="-R" ;;
        *) ;;
    esac
    echo "Starting quicly server ..."
    echo "SERVER_PARAMS:" $SERVER_PARAMS "TEST_PARAMS:" $TEST_PARAMS
    echo "/quicly/cli $SERVER_PARAMS $TEST_PARAMS -k /quicly/server.key -c /quicly/server.crt -e /logs/$TESTCASE.out 0.0.0.0 443"
    /quicly/cli $SERVER_PARAMS $TEST_PARAMS -k /quicly/server.key -c /quicly/server.crt  -e /logs/$TESTCASE.out 0.0.0.0 4434
fi
