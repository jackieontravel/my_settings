#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "Error:\n  This script must be sourced, not executed." >&2
    echo -e "Usage:\n  source $0" >&2
    exit 1
fi


# Function for settings based on hostname
apply_settings() {
    # Get the current hostname
    HOSTNAME=$(hostname)

    case "$HOSTNAME" in
        j01)
            WORKDIR=$HOME/github_jackieontravel/my_settings/linux
            BASHRC=.bashrc.j01
            ;;
        turtle)
            WORKDIR=$HOME/github/my_settings/linux
            BASHRC=.bashrc.turtle
            ;;
        leopard)
            WORKDIR=$HOME/github/my_settings/linux
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
    cp $WORKDIR/$BASHRC ~/.bashrc -v
    cp $WORKDIR/.bashrc_func.sh ~ -v
    cp $WORKDIR/.bashrc_func_vcs.sh ~ -v
    cp $WORKDIR/.bashrc_func_vcs_svn.sh ~ -v
    cp $WORKDIR/.bashrc_func_vcs_git.sh ~ -v
    
    # Terminal 256 colors support (Jackie version)
    cp $WORKDIR/256colors_j.pl ~/tools -v
    
    # SSH key checksum tools
    cp $WORKDIR/get_ssh_sum.sh ~/.ssh -v
    
    echo -e "\n\nsource ~/.bashrc ..."
    source ~/.bashrc
    echo "DONE"
}

apply_settings

echo "Settings applied successfully!"
