#!/bin/bash

if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
    # Action 1: Battery present
    echo "Battery detected - performing action 1"
    # Add your action 1 commands here
else
    # Action 2: No battery
    echo "No battery detected - performing action 2"
    # Add your action 2 commands here
fi
