#!/bin/bash

# Iterate over all .pub files in the current directory
echo -e "* List checksum (SHA256 & MD5) for all .pub files"
for file in *.pub; do
    # Skip if no .pub files exist
    [ -e "$file" ] || continue

    echo "File: $file"

    # Show SHA-256 checksum
    ssh-keygen -E sha256 -lf "$file"

    # Show MD5 checksum
    ssh-keygen -E md5 -lf "$file"

    echo  # Print an empty line for readability
done


echo -e "\n* Details on how to manage these files, see OneNote: \"Github Multiple Accounts\""
