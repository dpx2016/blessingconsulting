#!/bin/bash

# Define the group name from FreeIPA
SFTP_GROUP="vpnusers"

# Get all members of the group from LDAP/SSSD
USERS=$(getent group $SFTP_GROUP | cut -d: -f4 | sed 's/,/ /g')

for USER in $USERS; do
    HOMEDIR=$(getent passwd $USER | cut -d: -f6)
    sudo mkdir -p "$HOMEDIR"
    if [ -d "$HOMEDIR" ]; then
        echo "Processing $USER at $HOMEDIR..."
        
        # 1. Chroot requirement: Root must own the home dir, and it cannot be group-writable
        sudo chown root:root "$HOMEDIR"
        sudo chmod 755 "$HOMEDIR"

        # 2. Create a writable subdirectory for the user
        sudo mkdir -p "$HOMEDIR/uploads"
        sudo chown "$USER":"$SFTP_GROUP" "$HOMEDIR/uploads"
        sudo chmod 770 "$HOMEDIR/uploads"
        
        echo "Success: $USER can now upload to $HOMEDIR/uploads"
    else
        echo "Skip: $HOMEDIR does not exist for $USER yet."
    fi
done