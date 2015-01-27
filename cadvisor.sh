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
nsenter --mount=/host/proc/1/ns/mnt -- "${FILE}" "$@"
