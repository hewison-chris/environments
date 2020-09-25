#!/bin/bash

## Setup script used by the 'main' template in KimSufi
## The script is executed after a successful installation
## A return value of 0 is expected
## Alternatively, the following can be used to run this manually:
## curl -fsS https://raw.githubusercontent.com/bpfkorea/environments/master/setup.sh | bash

set -xeu
set -o pipefail

# Useful globals
BASE_DIR=/root/environments
HOSTS=(eu-001 eu-002 na-001 na-002)
DOMAIN=bosagora.io

# Install all required packages
apt-get install -y build-essential ecryptfs-utils emacs-nox gdb git lldb mosh zsh

# Setup for D packages
if [ ! -r /etc/apt/sources.list.d/d-apt.list ]; then
    wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
    apt-get update --allow-insecure-repositories
    apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
fi
# Setup for Eternal Terminal
add-apt-repository -y ppa:jgmath2000/et
# Setup for Docker (Ubuntu's 'docker' package is for docking windows)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install extra packages
apt-get update && apt-get install -y dmd-compiler dmd-tools ldc dub \
                          docker-ce docker-ce-cli containerd.io \
                          et


# Clone this repository to access required files
if [ -d ${BASE_DIR} ]; then
    git -C ${BASE_DIR} pull --ff-only
else
    git clone https://github.com/bpfkorea/environments.git ${BASE_DIR}/
fi

${BASE_DIR}/users/setup.sh

#########################################
# General configuration for all servers #
#########################################

# Allow passwordless sudo for users
sed -i -E -e 's/^[[:space:]]*\%sudo[[:space:]]+ALL=.*$/%sudo ALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers

# Disallow root ssh
sed -i -E -e 's/^[[:space:]]*PermitRootLogin[[:space:]]+.*$/PermitRootLogin no/g' /etc/ssh/sshd_config

# Install prometheus monitoring tool
if ! /usr/bin/which -s prometheus-node-exporter; then
    NODE_EXPORTER_VERSION=1.0.1
    NODE_EXPORTER_FILE=node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
    if [ ! -r /root/${NODE_EXPORTER_FILE}.tar.gz ]; then
        wget -O ${NODE_EXPORTER_TAR}.tar.gz https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}.tar.gz
    fi
    if [ ! -d /root/${NODE_EXPORTER_FILE} ]; then
        cd /root
        tar -xf /root/${NODE_EXPORTER_FILE}.tar.gz
    fi
    cp /root/${NODE_EXPORTER_FILE}/prometheus /usr/bin/
    cp /root/${NODE_EXPORTER_FILE}/promtool   /usr/bin/
    cp ${BASE_DIR}/servers/all/usr/lib/systemd/prometheus-node-exporter.service /usr/lib/systemd/prometheus-node-exporter.service
    cp ${BASE_DIR}/servers/all/etc/default/prometheus-node-exporter /etc/default/prometheus-node-exporter
fi

# TODO: Configure hosts, and per-server setup
