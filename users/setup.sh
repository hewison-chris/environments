#!/bin/bash

set -eu
set -o pipefail

SELF_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Add any user that is not on the system and copy their file
# TODO: Support copying missing files and overwriting old ones

# Process root first
cp -Rv ${SELF_PATH}/root/. /root/

# Then all dev team members
for userpath in ${SELF_PATH}/*; do
    # Skip non-directory, such as this file
    if [ ! -d ${userpath} ]; then continue; fi

    user=$(basename ${userpath})
    if [ ${user} = "root" ]; then continue; fi
    if [ -d /home/${user}/ ]; then
        echo "User '$user' home already exists, skipping"
        continue
    fi

    echo "Adding user '$user' ($userpath)..."
    adduser --shell `which zsh` --disabled-password --gecos "" --ingroup sudo ${user}
    cp -Rv ${userpath}/. /home/${user}/
    chmod 700 /home/${user}/.ssh/

    # Make sure to keep this the last action
    chown -R ${user}:sudo /home/${user}/
done

