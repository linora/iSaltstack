#!/bin/bash

systemctl start mongod.service
systemctl start rabbitmq-server.service
systemctl start nginx

st2ctl restart-component st2stream
st2ctl restart-component st2actionrunner
st2ctl restart-component st2api
st2ctl restart-component st2auth
st2ctl restart-component st2garbagecollector
st2ctl restart-component st2notifier
