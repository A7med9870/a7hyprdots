#!/usr/bin/env bash

folder="$HOME/Documents/obsi/"
vault_name="obsi"  # Your Obsidian vault name

# Find all .md files recursively, format paths relative to $folder
list_notes() {
  find "$folder" -type f -name "*.md" | sed "s|^$folder||" | sort
}

newnote() {
  name=$(rofi -dmenu -p "Enter name:" -theme-str 'entry { placeholder: "Note name..."; }') || exit 0
  : "${name:=$(date +%F_%T | tr ':' '-')}"
  # Ensure .md extension is added if not present
  [[ "$name" != *.md ]] && name="$name.md"
  xdg-open "obsidian://open?vault=$vault_name&file=$name&new=true" >/dev/null 2>&1
}

Todays_note() {
    # Open today's note in a new window
    xdg-open "obsidian://open?vault=$vault_name&file=/Daily%20Notes/$(date +%Y)/$(date +%b | tr '[:upper:]' '[:lower:]')/$(date +%F).md&new=true" >/dev/null 2>&1
}

Find_in_Text() {
    /home/ahmed/.config/hypr/rofi/scripts/ripgrepnotes.sh
}

selected() {
  choice=$(echo -e "Todays_note\nNew\nFind_in_Text\n$(list_notes)" | rofi -dmenu -i -p "Notes:" -lines 5 -matching fuzzy)

  case "$choice" in
    "New") newnote ;;
    "Todays_note") Todays_note ;;
    "Find_in_Text") Find_in_Text ;;
    *.md) xdg-open "obsidian://open?vault=$vault_name&file=$choice&new=true" >/dev/null 2>&1 ;;
    *) exit ;;
  esac
}

selected
