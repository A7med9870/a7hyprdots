#!/bin/bash

# Define the main categories and their sub-options
declare -A options=(
    ["obs"]="-ses -ins"
    ["forset"]="-seq -insd"
    ["other"]="-opt1 -opt2"
)

# Main categories array
main_categories=("obs"
  "forset"
  "other")

# Function to display main menu
show_main_menu() {
    echo "Available categories:"
    for i in "${!main_categories[@]}"; do
        echo "$((i+1)). ${main_categories[i]}"
    done
}

# Function to get random main category
get_random_main() {
    local random_index=$((RANDOM % ${#main_categories[@]}))
    echo "${main_categories[random_index]}"
}

# Function to get random sub-option
get_random_sub() {
    local main_category=$1
    local sub_options=(${options[$main_category]})
    local random_index=$((RANDOM % ${#sub_options[@]}))
    echo "${sub_options[random_index]}"
}

# Main script
# echo "Random Selection Script"
# echo "======================"
#
# Get random main category
main_choice=$(get_random_main)
# echo "Selected category: $main_choice"
echo "Selected category: $main_choice"

# Get random sub-option based on main category
sub_choice=$(get_random_sub "$main_choice")
# echo "Selected option: $sub_choice"

# echo "Final result: $main_choice $sub_choice"
echo "$main_choice $sub_choice"
