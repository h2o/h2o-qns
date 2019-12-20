#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh
cd quicly

if [ ! -z "$TESTCASE" ]; then
    case "$TESTCASE" in
        "handshake"|"transfer"|"retry"|"goodput"|"resumption") ;;
        "http3") exit 127 ;;
        *) exit 127 ;;
    esac
fi

### Client side ###
if [ "$ROLE" == "client" ]; then
    # Wait for the simulator to start up.
    /wait-for-it.sh sim:57832 -s -t 30
    cd /downloads
    case "$TESTCASE" in
        "resumption") TEST_PARAMS="-s previous_sessions.bin" ;;
        *) ;;
    esac
    echo "Starting quicly client ..."
    if [ ! -z "$REQUESTS" ]; then
        # pull requests out of param
        echo "Requests: " $REQUESTS
        for REQ in $REQUESTS; do
            FILE=`echo $REQ | cut -f4 -d'/'`
            if [ "$TESTCASE" == "resumption" ]; then
                FILELIST=${FILELIST}" /"${FILE}
            else
                FILES=${FILES}" -P /"${FILE}
            fi
        done

        if [ "$TESTCASE" == "resumption" ]; then
            FILE=`echo $FILELIST | cut -f1 -d" "`
            echo "/quicly/cli -P $FILE server 443"
            /quicly/cli -P $FILE $TEST_PARAMS -a "hq-24" -x x25519 -x secp256r1 -e /logs/$TESTCASE.out server 443
            for FILE in `echo $FILELIST | cut -f2- -d" "`; do
                FILES=${FILES}" -P "${FILE}
            done
            echo "/quicly/cli $FILES server 443"
            /quicly/cli $FILES $TEST_PARAMS -a "hq-24" -x x25519 -x secp256r1 -e /logs/$TESTCASE.out server 443
            rm -f previous_sessions.bin
        else
            echo "/quicly/cli $FILES server 443"
            /quicly/cli $FILES $TEST_PARAMS -a "hq-24" -x x25519 -x secp256r1 -e /logs/$TESTCASE.out server 443
        fi

        # cleanup
        for REQ in $REQUESTS; do
            FILE=`echo $REQ | cut -f4 -d'/'`
            mv $FILE.downloaded $FILE
        done
    fi

### Server side ###
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
    /quicly/cli $SERVER_PARAMS $TEST_PARAMS -k /quicly/server.key -c /quicly/server.crt -x x25519 -x secp256r1 -a "hq-24" -e /logs/$TESTCASE.out 0.0.0.0 443
fi
