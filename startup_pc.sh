#!/bin/bash

/home/ahmed/.config/hypr/scripts/Copy_VRC_screenshots.sh
/home/ahmed/.config/hypr/scripts/Copy_minecraft_screenshots.sh
/home/ahmed/.config/hypr/scripts/Copy_steam_screenshots.sh
/home/ahmed/.config/hypr/scripts/STEAM_BACKGROUND_RECORDING/Steam_clip_batch_convert.sh
/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/Videos/converted/
cp -p -u /home/ahmed/Cameraxio/Camera/*.mp4 /run/media/ahmed/drived/just_vids/

cp -p -u /home/ahmed/Videos/converted/*.mkv /home/ahmed/Videos/LinuxPC_Videos/
cp -p -u /home/ahmed/Videos/*.mp4 /home/ahmed/videos_uncomprassed/
/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/videos_uncomprassed/

/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/Cameraxio/Camera/
/home/ahmed/.config/hypr/scripts/Delete_Mp4_if_mkv_exists_of_same_video.sh /home/ahmed/Cameraxio/Camera/
/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/Cameraxio/ScreenRecorder/
/home/ahmed/.config/hypr/scripts/Delete_Mp4_if_mkv_exists_of_same_video.sh /home/ahmed/Cameraxio/ScreenRecorder/

cp -p -u /home/ahmed/Videos/ins_videos/*.mp4 /home/ahmed/Documents/BlenderProjects/videos/
/home/ahmed/.config/hypr/scripts/compress_videos_nvidia.sh /home/ahmed/Videos/Phone_movies/Instagram/
/home/ahmed/.config/hypr/scripts/Delete_Mp4_if_mkv_exists_of_same_video.sh /home/ahmed/Videos/Phone_movies/Instagram/
# /home/ahmed/.config/hypr/obsish/delete_mp4.sh

cp -p -u /home/ahmed/videos_uncomprassed/*.mkv /home/ahmed/Videos/LinuxPC_Videos/
cp -p -u /home/ahmed/Videos/*.mp4 /run/media/ahmed/drivec/just_vids/
cp -p -u /home/ahmed/Videos/*.mp4 /run/media/ahmed/drived/just_vids/
cp -p -u -r /run/media/ahmed/drived/Steam_rec/clips/ /home/ahmed/Documents/BlenderProjects/
/home/ahmed/.config/hypr/scripts/jpg2jxl.sh /home/ahmed/Pictures/Screenshots/
/home/ahmed/.config/hypr/scripts/jpg2jxl.sh /home/ahmed/Cameraxio/Camera/
/home/ahmed/.config/hypr/scripts/jpg2jxl.sh /home/ahmed/Pictures/Scrn_Shoots_Phone/
/home/ahmed/.config/hypr/scripts/jpg2jxl.sh /home/ahmed/Pictures/Quest_scrn/
/home/ahmed/.config/hypr/scripts/jpg2jxl.sh /home/ahmed/Pictures/Laptopscreensshots/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Pictures/Screenshots/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Pictures/Screenshots/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Cameraxio/Camera/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Pictures/Scrn_Shoots_Phone/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Pictures/Quest_scrn/
/home/ahmed/.config/hypr/scripts/jpg2jxl_clean.sh /home/ahmed/Pictures/Laptopscreensshots/
# cp -p -u -r /run/media/ahmed/drived/Steam_rec/clips/. /home/ahmed/Documents/BlenderProjects/clips/
