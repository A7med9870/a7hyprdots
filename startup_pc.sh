#!/bin/bash

/home/ahmed/.config/hypr/scripts/Copy_VRC_screenshots.sh
/home/ahmed/.config/hypr/scripts/Copy_minecraft_screenshots.sh
/home/ahmed/.config/hypr/scripts/STEAM_BACKGROUND_RECORDING/Steam_clip_batch_convert.sh
/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/Videos/converted/

cp -p -u /home/ahmed/Videos/converted/*.mkv /home/ahmed/Videos/LinuxPC_Videos/
cp -p -u /home/ahmed/Videos/*.mp4 /home/ahmed/videos_uncomprassed/
/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/videos_uncomprassed/
cp -p -u /home/ahmed/videos_uncomprassed/*.mkv /home/ahmed/Videos/LinuxPC_Videos/
cp -p -u /home/ahmed/Videos/*.mp4 /run/media/ahmed/drivec/just_vids/
cp -p -u -r /run/media/ahmed/drived/Steam_rec/clips/ /home/ahmed/Documents/BlenderProjects/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Pictures/Screenshots/
# cp -p -u -r /run/media/ahmed/drived/Steam_rec/clips/. /home/ahmed/Documents/BlenderProjects/clips/
