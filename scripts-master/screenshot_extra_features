#!/usr/bin/env bash

# expansion of the imagemagick screenshot script with:
# - hex code color picker (slop + imagemagick)
# - copy to clipboard (xclip)
# - screenshot current window directly (no selection)

export DISPLAY=:0
FILE="$HOME/$(date +%F___%T | tr ':' '-').png"

colorpicker () { # click a pixel OR draw a selection for average color, returned in a notif & copied to clip
TMP="/tmp/color.png"

# slop's tolerance flag controls how far mouse can be move before being detected as a click and drag
# would recommend use of slop as it allows for 1x1 selection
if command -v slop >/dev/null; then 
		import -window root -crop "$(slop --tolerance=0 || exit 0)" "$TMP"
else 
		import "$TMP"
fi

HEX=$(magick "$TMP" -scale 1x1\! -format "#%[hex:p{0,0}]" info:) # SRGB: '%[pixel:p{0,0}]'

notify-send -i "$TMP" $HEX # set the tmp img as the notif icon
echo "$HEX" | xclip -i -selection clipboard # copy to clip
rm "$TMP"
}


full () { # full screen incl. all monitors
		import -window root "$FILE" && post
}


window () { # focused window
		import -window "$(xdotool getwindowfocus -f)" "$FILE"
}


selection () { # draw a selection, or click to select a window
		import "$FILE" && post
}


post () { # copy image to clip & send a notification
		xclip -selection clipboard -t image/png -i $FILE && notify-send -i "$FILE" "$FILE copied to clipboard"
}


case "$1" in
		color*) colorpicker ;;
		full) full ;;
		window) window ;;
		*) selection ;;
esac

# watermark automation example
# !! repage for centered gravity when screenshotting a selection !!
# import png:- | magick - +repage -gravity center -fill white -undercolor '#00000080' -pointsize 50 -annotate 0 'bread' watermark.png
