#!/bin/bash

# Source and target directories
src_dir="/home/ahmed/Documents/obsi/Daily Notes"
target_dir="/home/ahmed/Documents/Extracted"
obsidian_css="/home/ahmed/Documents/obsi/.obsidian/themes/Obsidian Nord/theme.css"

# Create target directory if it doesn't exist
mkdir -p "$target_dir"

# Find and process markdown files
find "$src_dir" -type f -name "*.md" | while read -r filepath; do
    # Extract year and month from path
    year=$(echo "$filepath" | grep -oP '(?<=/)[0-9]{4}(?=/)' | head -1)
    month=$(dirname "$filepath" | xargs basename)
    filename=$(basename "$filepath" .md)

    mkdir -p "$target_dir/$year/$month"
    temp_dir=$(mktemp -d)

    # 1. Create a complete HTML document with Obsidian's structure
    {
        echo '<!DOCTYPE html>'
        echo '<html lang="en" class="theme-dark">'
        echo '<head>'
        echo '  <meta charset="UTF-8">'
        echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0">'
        echo "  <style>"
        # Embed the CSS directly to ensure it loads
        cat "$obsidian_css"
        echo '  </style>'
        echo '  <style>'
        echo '    .markdown-preview-view {'
        echo '      max-width: 900px;'
        echo '      margin: 0 auto;'
        echo '      padding: 40px;'
        echo '    }'
        echo '    body {'
        echo '      background-color: var(--background-primary) !important;'
        echo '      color: var(--text-normal) !important;'
        echo '    }'
        echo '    /* Force specific element styles */'
        echo '    pre, code { font-family: var(--font-monospace) !important; }'
        echo '    hr { background-color: var(--background-modifier-border) !important; }'
        echo '  </style>'
        echo '</head>'
        echo '<body>'
        echo '<div class="markdown-preview-view">'
        # 2. Convert with Pandoc using Obsidian-compatible settings
        pandoc -f markdown+hard_line_breaks+task_lists+emoji \
               -t html \
               --columns=900 \
               --wrap=preserve \
               "$filepath"
        echo '</div>'
        echo '</body>'
        echo '</html>'
    } > "$temp_dir/note.html"

    # 3. Convert to PNG with precise rendering settings
    echo "Converting: $filepath"
    wkhtmltoimage --quality 100 \
                  --enable-local-file-access \
                  --width 1200 \
                  --zoom 1.0 \
                  --disable-smart-width \
                  --no-images \
                  --custom-header "User-Agent" "Mozilla/5.0" \
                  --custom-header-propagation \
                  --javascript-delay 500 \
                  "$temp_dir/note.html" "$target_dir/$year/$month/$filename.png" 2>/dev/null

    # 4. Preserve original timestamp
    timestamp=$(stat -c "%y" "$filepath")
    touch -d "$timestamp" "$target_dir/$year/$month/$filename.png"

    # 5. Optional debug output
    # cp "$temp_dir/note.html" "$target_dir/$year/$month/$filename.html"

    rm -rf "$temp_dir"
    echo "Created: $target_dir/$year/$month/$filename.png"
done

echo "Conversion complete!"
