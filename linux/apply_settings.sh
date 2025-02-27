#!/bin/bash

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
    cp $BASHRC ~/.bashrc -v
    cp .bashrc_func.sh ~/.bashrc_func.sh -v
    cp 256colors_j.pl ~/tools -v
    
    echo -e "\n\nsource ~/.bashrc ..."
    source ~/.bashrc
    echo "DONE"
}

# Apply settings
apply_settings

echo "Settings applied successfully!"
