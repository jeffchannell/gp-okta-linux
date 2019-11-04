#!/usr/bin/env bash

# Tested on Xubuntu 19.10 and CentOS 8

set -e

if [ -f /var/run/gp-okta.pid ]; then
    sudo kill "$(cat /var/run/gp-okta.pid)"
fi
