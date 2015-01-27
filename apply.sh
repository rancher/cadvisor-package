#!/bin/bash

source ${CATTLE_HOME:-/var/lib/cattle}/common/scripts.sh

mkdir -p content-home/bin
cp dist/{cadvisor,cadvisor.sh} content-home/bin
chmod +x content-home/bin/cadvisor

stage_files
