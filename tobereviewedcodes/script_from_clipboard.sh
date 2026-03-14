#!/bin/bash
# script_from_clipboard.sh

# Get clipboard content
content=$(wl-paste)

if [ -z "$content" ]; then
    echo "Clipboard is empty!"
    exit 1
fi

# Generate filename
filename="script_$(date +%Y%m%d_%H%M%S).sh"

# Create file with proper shebang
{
    if [[ ! "$content" =~ ^#!/ ]]; then
        echo "#!/bin/bash"
        echo ""
    fi
    echo "$content"
} > "$filename"

# Make executable
chmod +x "$filename"

echo "Created executable script: $filename"
ls -la "$filename"
