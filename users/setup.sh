#!/bin/bash

set -xeu
set -o pipefail

# Add any user that is not on the system and copy their file
# TODO: Support copying missing files and overwriting old ones

# Process root first
cp -Rv ${file} /root/.

# Then all dev team members
for userpath in $BASE_DIR/users/*; do
    user=$(basename userpath)
    if [ $user -eq "root" ]; then continue; fi
    if [ -d /home/$user/ ]; then
        echo "User '$user' home already exists, skipping"
    fi
    
    adduser --shell `which zsh` --disabled-password --ingroup sudo $user
    cp -Rv $userpath/. /home/$user/
    chmod 700 /home/$user/.ssh/

    # Make sure to keep this the last action
    chown -R $user:sudo /home/$user/
done

