#!/usr/bin/env bash

folder="$HOME/Documents/obsi/"

# Find all .md files recursively, format paths relative to $folder
list_notes() {
  find "$folder" -type f -name "*.md" | sed "s|^$folder||" | sort
}

newnote() {
  name=$(rofi -dmenu -p "Enter name:" -theme-str 'entry { placeholder: "Note name..."; }') || exit 0
  : "${name:=$(date +%F_%T | tr ':' '-')}"
  # Ensure .md extension is added if not present
  [[ "$name" != *.md ]] && name="$name.md"
  setsid -f alacritty -e micro "$folder$name" >/dev/null 2>&1
}

Todays_note() {
    alacritty -e /home/ahmed/.config/hypr/open_daily_note.sh
}

Find_in_Text() {
    /home/ahmed/.config/hypr/rofi/scripts/ripgrepnotes.sh
}

selected() {
  # choice=$(echo -e "New\nkabash\nAnotherOption\n$(list_notes)" | rofi -dmenu -p "Notes:" -lines 5 -matching fuzzy)
  choice=$(echo -e "Todays_note\nNew\nFind_in_Text\n$(list_notes)" | rofi -dmenu -i -p "Notes:" -lines 5 -matching fuzzy)

  case "$choice" in
    "New") newnote ;;
    "Todays_note") Todays_note ;;
    "Find_in_Text") Find_in_Text ;;
    # "AnotherOption") your_new_function ;;
    *.md) setsid -f alacritty -e micro "$folder$choice" >/dev/null 2>&1 ;;
    *) exit ;;
  esac
}
selected
