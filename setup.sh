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
apt-get install build-essential docker ecryptfs-utils emacs-nox gdb git lldb mosh zsh

# Install D packages
wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
apt-get update --allow-insecure-repositories
apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
apt-get update && sudo apt-get install dmd-compiler dmd-tools ldc dub

# Clone this repository to access required files
git clone https://github.com/bpfkorea/environments.git $BASE_DIR/

$BASE_DIR/users/setup.sh

#########################################
# General configuration for all servers #
#########################################

# Allow passwordless sudo for users
sed -i -e 's/^[[:space:]]*\%sudo[[:space:]+ALL=(ALL).*$/%sudo ALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers

# Disallow root ssh
sed -i -e 's/^[[:space:]]*PermitRootLogin[[:space:]]?.*/PermitRootLogin no/g' /etc/sshd/sshd_confi

# TODO: Configure hosts, and per-server setup
