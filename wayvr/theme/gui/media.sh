#! /bin/bash
# I should live in ~/.config/wayvr/theme/gui/media.sh next to media.xml

#Define the full path of WayVRCTL command here if needed.
WAYVRCTL="/home/$USER/.cargo/bin/wayvrctl";

#Check for needed XDG Runtime variable
if [ -z "$XDG_RUNTIME_DIR" ] ; then
    exit ERRCODE "XDG_RUNTIME_DIR var not set." ;
fi

# Placeholder album art URL.
PLACEHOLDER_ART="https://openclipart.org/image/50px/27648";

#Define some initial values (Working variables)
LASTART="";
LASTMETA="";
LF=$(printf \n);
spin='-\|/';

#Clear placeholder text
curl $PLACEHOLDER_ART > $XDG_RUNTIME_DIR/albumArt;
METADATA="
panel-modify media run_btn_div set-visible 0
panel-modify media nowPlaying_artist set-text No media playing
panel-modify media nowPlaying_title set-text -
panel-modify media nowPlaying_album set-text -
panel-modify media nowPlaying_art set-image $XDG_RUNTIME_DIR/albumArt";
echo "$METADATA" | $WAYVRCTL batch;

#Begin Looping
while true; do
    # (Not used) JSON_DATA=$(playerctl metadata --format "{ 'album_art': '{{ mpris:artUrl }}', 'artist': '{{ artist }}', 'title': '{{ title }}', 'album': '{{ album }}'}");
    # Not all media players are created equal, Let's cache/copy the current album art to a local file using CURL in case the URI differs.
    ARTURL=$(playerctl -s metadata mpris:artUrl);
    # First check there's even a URL there, and if not - Slip in a placeholder.
    if [ "$ARTURL" == "" ]; then
        ARTURL=$PLACEHOLDER_ART;
    fi
    # Compare what was last seen to what's current, we should avoid repeatedly downloading (Web URL) and/or writing to disk/memory.
    if [ "$ARTURL" != "$LASTART" ]; then
        echo " (Art change detected) ";
        curl $ARTURL > $XDG_RUNTIME_DIR/albumArt;

        # Update LastArt var to store the new change
        LASTART=$ARTURL;

        # Tell WayVR to update the album art
        $WAYVRCTL panel-modify media nowPlaying_art set-image $XDG_RUNTIME_DIR/albumArt;
    fi
    # Assemble the Batch Command
    # We can actually ask playerctl to format its output however we want
    METADATA=$(playerctl -s metadata --format "
        panel-modify media nowPlaying_artist set-text {{ artist }}
        panel-modify media nowPlaying_title set-text {{ title }}
        panel-modify media nowPlaying_album set-text {{ album }}");
    if [ "$METADATA" != "$LASTMETA" ]; then
        echo " (Metadata change detected) ";
        # Store the Metadata as a variable for the comparator
        LASTMETA=$METADATA;
        # - pipe it directly in to wayvrctl as a batch command.
        echo "$METADATA" | $WAYVRCTL batch;
    fi
    # Spin Spin Spin
    i=$(( (i+1) %4 ));
    printf "\r [$(date)] - Working ${spin:$i:1}";
    sleep 1;
done
