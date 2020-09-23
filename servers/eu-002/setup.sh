#!/bin/bash

## Setup the nodes running on this server

set -xeu
set -o pipefail

SELF_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

cp -Rv ${SELF_PATH}/srv /
cp -Rv ${SELF_PATH}/usr /
