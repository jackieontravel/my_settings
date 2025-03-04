#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "Error:\n  This script must be sourced, not executed." >&2
    echo -e "Usage:\n  source $0" >&2
    exit 1
fi


# Get the current hostname
HOSTNAME=$(hostname)

# Function for settings based on hostname
apply_settings() {
    case "$HOSTNAME" in
        j01)
            BASHRC=.bashrc.j01
            ;;
        turtle)
            BASHRC=.bashrc.turtle
            ;;
        leopard)
            BASHRC=.bashrc.leopard
            ;;
        *)
            echo "Unknown hostname: $HOSTNAME"
            exit 1
            ;;
    esac
    
    # Carry on if not exist
    echo "Applying settings for $HOSTNAME..."
    # bash functions:
    cp $BASHRC ~/.bashrc -v
    cp .bashrc_func.sh ~ -v
    cp .bashrc_func_git.sh ~ -v
    
    # Terminal 256 colors support (Jackie version)
    cp 256colors_j.pl ~/tools -v
    
    # SSH key checksum tools
    cp get_ssh_sum.sh ~/.ssh -v
    
    echo -e "\n\nsource ~/.bashrc ..."
    source ~/.bashrc
    source ~/.bashrc_func_git.sh
    echo "DONE"
}

apply_settings

echo "Settings applied successfully!"
