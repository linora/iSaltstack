#!/bin/bash

SALT_STATE_HOME="${SALT_STATE_HOME}"

/usr/bin/python2.7 \
${SALT_STATE_HOME}/slack/py/iSlack.py "$(ls -lrt)"
