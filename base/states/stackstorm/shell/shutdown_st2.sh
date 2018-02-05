#!/bin/bash

st2ctl stop

systemctl stop nginx
systemctl stop mongod.service
systemctl stop rabbitmq-server.service
