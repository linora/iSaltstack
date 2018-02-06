#!/bin/bash

rpm -qa | grep -i ^mysql | xargs rpm -e --nodeps
rm -rf /app/mysql/*
