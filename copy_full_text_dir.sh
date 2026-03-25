#!/bin/bash

# Get current date in YY_MM_DD_HH format
current_date=$(date +"%y_%m_%d_%H")

# Define the output file with dynamic name
output_file="$HOME/Documents/obsi/Hypr/${current_date}.md"

# Function to append file content in the desired format
# append_file_content() {
#     local file_path="$1"
#     # Expand ~ to the full home directory path
#     file_path=$(eval echo "$file_path")
#     local file_name=$(basename "$file_path")
#     local relative_path="${file_path#$HOME/.config/hypr/}"

#     echo "$relative_path" >> "$output_file"
#     echo "---" >> "$output_file"
#     echo "\`\`\`" >> "$output_file"
#     echo "$file_path" >> "$output_file"
#     echo "\`\`\`" >> "$output_file"
#     echo "\`\`\`" >> "$output_file"
#     cat "$file_path" >> "$output_file"
#     echo "\`\`\`" >> "$output_file"
#     echo "---" >> "$output_file"
# }
append_file_content() {
    local file_path="$1"
    # Expand ~ to the full home directory path
    file_path=$(eval echo "$file_path")
    local file_name=$(basename "$file_path")
    local relative_path="${file_path#$HOME/.config/hypr/}"
    local file_ext="${file_name##*.}"
    local lang_identifier=""

    # Determine language identifier based on file extension
    case "$file_ext" in
        sh)      lang_identifier="bash" ;;
        bash)    lang_identifier="bash" ;;
        zsh)     lang_identifier="bash" ;;
        fish)    lang_identifier="bash" ;;
        py)      lang_identifier="python" ;;
        js)      lang_identifier="javascript" ;;
        json)    lang_identifier="json" ;;
        jsonc)   lang_identifier="json" ;;
        xml)     lang_identifier="xml" ;;
        html)    lang_identifier="html" ;;
        css)     lang_identifier="css" ;;
        rasi)    lang_identifier="css" ;;
        ini)     lang_identifier="ini" ;;
        conf)    lang_identifier="ini" ;;
        rc)      lang_identifier="sh" ;;
        md)      lang_identifier="markdown" ;;
        txt)     lang_identifier="text" ;;
        *)       lang_identifier="" ;;
    esac

    echo "$relative_path" >> "$output_file"
    echo "---" >> "$output_file"
    echo "\`\`\`" >> "$output_file"
    echo "$file_path" >> "$output_file"
    echo "\`\`\`" >> "$output_file"

    # Add language identifier if one was determined
    if [ -n "$lang_identifier" ]; then
        echo "\`\`\`$lang_identifier" >> "$output_file"
    else
        echo "\`\`\`" >> "$output_file"
    fi

    cat "$file_path" >> "$output_file"
    echo "\`\`\`" >> "$output_file"
    echo "---" >> "$output_file"
}

# Function to recursively process all text files in a directory
process_directory() {
    local dir_path="$1"
    # Expand ~ to the full home directory path
    dir_path=$(eval echo "$dir_path")

    # Find all files in the directory and subdirectories
    while IFS= read -r -d '' file; do
        # Check if file is a text file (more comprehensive check)
        if file -b --mime-encoding "$file" | grep -qvi 'binary'; then
            append_file_content "$file"
        fi
    done < <(find "$dir_path" -type f \( -name "*.conf" -o -name "*.sh" -o -name "*.css" -o -name "*.rasi" -o -name "*.json" -o -name "*.jsonc" -o -name "*.md" -o -name "*.txt" -o -name "*.fish" -o -name "*.ini" -o -name "*.rc" \) -print0)
}

# Process specific individual files (outside hypr directory)
# append_file_content "~/.local/share/kxmlgui5/dolphin/dolphinui.rc"
# append_file_content "~/.config/dolphinrc"
# append_file_content "~/.config/qt5ct/qt5ct.conf"
# append_file_content "~/.config/kdeglobals"
# append_file_content "~/.config/gtk-3.0/settings.ini"
# append_file_content "~/.config/menus/applications.menu"
# append_file_content "~/.config/fish/config.fish"
# append_file_content "~/.config/syncthingtray.ini"
# append_file_content "~/.config/spectaclerc"
# append_file_content "~/.config/ksnip/ksnip.conf"
# append_file_content "~/.bashrc"
# append_file_content "/etc/default/grub"

# Process all text files in the hypr directory and subdirectories
process_directory "~/.config/hypr/"
# process_directory "~/.config/steam-rom-manager/"
process_directory "~/Documents/obsi/Liuounx/insurgencysever_randommapconcpet/"

echo "File content has been copied to $output_file" && notify-send "${current_date}.md updated in obsi"
