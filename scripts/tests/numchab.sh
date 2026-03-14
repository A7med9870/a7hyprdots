#!/bin/bash

# Set default value
default_number=0
current_number=$default_number

echo "The current number is: $current_number"

# Prompt user with option to keep default
read -p "Enter a new number (or press Enter to keep current): " user_input

# Only update if user provided input
if [[ -n "$user_input" ]]; then
    if [[ $user_input =~ ^-?[0-9]+$ ]]; then
        current_number=$user_input
        echo "Number updated to: $current_number"
    else
        echo "Invalid input! Keeping current number: $current_number"
    fi
else
    echo "Keeping default number: $current_number"
fi
