#!/bin/bash

st2ctl stop

systemctl stop mongod.service
systemctl stop rabbitmq-server.service
systemctl stop nginx
