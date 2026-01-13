#!/bin/bash

# Input file format: FirstName LastName
INPUT_FILE=$1

if [[ -z "$INPUT_FILE" ]]; then
    echo "Usage: $0 <user_list_file>"
    exit 1
fi

if ! klist -s; then
    echo "Error: No valid Kerberos ticket found. Please run 'kinit admin' first."
    exit 1
fi

while IFS=' ' read -r first last; do
    # Skip empty lines
    [[ -z "$first" || -z "$last" ]] && continue

    # Generate lowercase username (e.g., john.doe)
    username=$(echo "${first}.${last}" | tr '[:upper:]' '[:lower:]')

    echo "Processing user: $username..."
    echo "First Name: $first, Last Name: $last"
    # 1. Create the user
    # Note: FreeIPA will require a password change on first login by default
    # ipa user-add "${username}" --first="${first}" --last="${last}" --password="${first}"

    echo -e "${first}\n${first}" | ipa user-add "${username}" \
        --first="${first}" \
        --last="${last}" \
        --password > /dev/null

    if [ $? -eq 0 ]; then
        echo "Successfully created user $username."
        
        # 2. Add user to the vpnusers group
        ipa group-add-member vpnusers --users="$username" > /dev/null
        echo "Added $username to 'vpnusers' group."
    else
        echo "Failed to create user $username (it might already exist)."
    fi

    echo "-----------------------------------"
done < <(tr -d '\r' < "$INPUT_FILE")