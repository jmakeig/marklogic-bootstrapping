#!/usr/bin/env bash

# Downloads Query Console workspaces to the current working directory in the format {host}_{workspace id}_{timestamp}.workspace.

if command -v jq >/dev/null; then
  :
else
  echo 'You need jq in order to parse JSON. <http://stedolan.github.io/jq/>'
  exit 1
fi

HOST=jmakeig-centos6-virtualbox.localdomain
USER=admin
PASSWORD='********'

curl -fsS "http://$HOST:8000/qconsole/endpoints/workspaces.xqy" --digest --user "$USER":"$PASSWORD" | jq --raw-output '.[].workspace[].id' | while read -r line; do
  printf "Exporting workspace $line from $HOST\n"
  curl  -fsS "http://$HOST:8000/qconsole/endpoints/workspaces.xqy?wsid=$line&format=export" --digest --user "$USER":"$PASSWORD" > "$HOST"_"$line"_$(date +"%Y-%m-%dT%H:%M:%SZ").workspace
done
