#!/bin/bash
set -e

# I know, I know... I really try to avoid hacks, but it's just so hard...

DIR=$(docker inspect rancher-agent | jq -r '.[0].Volumes["/var/log/rancher"]')

if [ -z "$DIR" ]; then
    echo "Failed to find volume root" 1>&2
    exit 1
fi

mkdir -p /var/log/rancher

FILE="${DIR}/.cadvisor"
LOCAL_FILE="/var/log/rancher/.cadvisor"

cp -f "$(which cadvisor)" "${LOCAL_FILE}"

del()
{
    sleep 1
    rm -f "${LOCAL_FILE}" || true
}

del &

shift 1

PID=$(echo $(ps -o ppid= -p $(docker inspect -f '{{.State.Pid}}' rancher-agent)))
if [ ! -d /proc/$PID ]; then
    PID=1
fi
echo Monitoring mount context of PID $PID
nsenter --mount=/host/proc/$PID/ns/mnt -- "${FILE}" "$@"
