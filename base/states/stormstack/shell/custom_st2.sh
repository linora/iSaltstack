#!/bin/bash

:<<CMMT
# st2ctl status
##### st2 components status #####
st2actionrunner is not running.
st2api is not running.
st2stream is not running.
st2auth is not running.
st2garbagecollector is not running.
st2notifier is not running.
st2resultstracker is not running.
st2rulesengine is not running.
st2sensorcontainer is not running.
st2chatops is not running.
mistral-server is not running.
mistral-api is not running.
CMMT

systemctl stop st2chatops.service;
systemctl disable st2chatops.service;

systemctl stop st2stream.socket;
systemctl disable st2stream.socket;

systemctl stop st2stream.service;
systemctl disable st2stream.service;

systemctl stop st2sensorcontainer.service;
systemctl disable st2sensorcontainer.service;

systemctl stop st2rulesengine.service;
systemctl disable st2rulesengine.service;

systemctl stop st2resultstracker.service;
systemctl disable st2resultstracker.service;

systemctl stop mistral-api.service;
systemctl disable mistral-api.service;

systemctl stop mistral-server.service;
systemctl disable mistral-server.service;

systemctl stop mistral.service;
systemctl disable mistral.service;

systemctl stop postgresql.service;
systemctl disable postgresql.service;
