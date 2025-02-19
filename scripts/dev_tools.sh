#!/bin/bash
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     command="xdg-open";;
    Darwin*)    command="open";;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${command}

if [[ -z "$1" ]]; then
    # list db, redis, rabbitmq, and seaweedfs ports
    docker ps --format '{{.Names}}' | grep "db\|redis\|queue\|seaweedfs" | xargs -I '{}' bash -c 'echo "{} -> $(python3 -c "import sys; [print(l.split(\":\")[-1]) for l in sys.argv[1].split(\"\n\") if l.split(\"/tcp\")[0] in sys.argv[2].split(\",\")]" "$(docker port {})" "15672,5432,6379,8888")"' - {}
else
    PORT=$1
    if docker ps | grep ":${PORT}" | grep -q 'redis'; then
        ${command} redis://127.0.0.1:${PORT}
    elif docker ps | grep ":${PORT}" | grep -q 'postgres'; then
        ${command} postgresql://postgres:changethis@127.0.0.1:${PORT}/app
    else
        ${command} http://localhost:${PORT}
    fi
fi
