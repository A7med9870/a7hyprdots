#!/bin/bash

input_md="$1"
output_png="$2"
output_html="${output_png%.png}.html"  # Keep HTML for debugging

# Convert markdown to HTML (no wrapper, no styling)
pandoc -f markdown -t html -o "$output_html" "$input_md"

# Convert HTML to PNG
wkhtmltoimage --quality 100 --width 1000 "$output_html" "$output_png"

echo "Conversion done:"
echo "HTML: $output_html"
echo "PNG: $output_png"
