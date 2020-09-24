#!/bin/bash

set -eu
set -o pipefail

SELF_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Add any user that is not on the system and copy their file
# TODO: Support copying missing files and overwriting old ones

# Process root first
cp -Rv ${SELF_PATH}/root/. /root/
chsh root -s `which zsh`

# Now add applications account
if ! cat /etc/shadow | grep -qE '^agora:'; then
    adduser --system --home /srv/agora/ --disabled-password --disabled-login --gecos "" agora
fi
chown -R agora:nogroup /srv/agora/
if ! cat /etc/shadow | grep -qE '^stoa:'; then
    adduser --system --home /srv/stoa/ --disabled-password --disabled-login --gecos "" stoa
fi
chown -R stoa:nogroup /srv/stoa/

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
    # Give grml zsh by default, but users can override it
    cp /root/.zshrc /home/${user}/.zshrc
    cp -Rv ${userpath}/. /home/${user}/
    chmod 700 /home/${user}/.ssh/

    # Make sure to keep this the last action
    chown -R ${user}:sudo /home/${user}/
done

