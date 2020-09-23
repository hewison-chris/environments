#!/bin/bash

## Setup the nodes running on this server

set -xeu
set -o pipefail

SELF_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

cp -Rv ${SELF_PATH}/srv /
cp -Rv ${SELF_PATH}/../common/usr /

mkdir -p /srv/stoa/

systemctl daemon-reload
systemctl enable agora@4.service
systemctl enable agora@5.service
# systemctl enable stoa.service

systemctl start agora@4.service
systemctl start agora@5.service
#systemctl start stoa.service
