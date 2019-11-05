#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -f /var/run/gp-okta.pid ] || [ "stop" == "${1}" ]; then
    if [ "status" == "${1}" ]; then
        echo -n "started"
        exit 0
    fi
    setsid "${DIR}/stop.sh" > /dev/null 2>&1 &
    echo -n "stopped"
else
    if [ "status" == "${1}" ]; then
        echo -n "stopped"
        exit 0
    fi
    setsid "${DIR}/start.sh" > /dev/null 2>&1 &
    echo -n "started"
fi
exit 0