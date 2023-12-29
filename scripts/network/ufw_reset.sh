#!/bin/bash

# Check if the number of arguments is exactly 1
if [ "$#" -eq 1 ]; then
    # If one argument is provided, run the ufw command with sudo
    sudo ufw delete allow from "192.168.1.1$1"
    sudo ufw status
else
    # If no argument is provided, display a usage message
    echo "Usage: $0 <xx>"
    echo "   where xx is the last two digits of your LiDARs Serial No. (backside QR code)"
fi