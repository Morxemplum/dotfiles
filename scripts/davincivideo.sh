#!/usr/bin/env bash

# Name: davincivideo.sh
# Author: Morxemplum, originally by Danie van der Merwe
# Depends on: ffprobe, ffmpeg
# Description: This is a shell script that takes videos that are using
#              unsupported codecs and transcodes them into production ready 
#              codecs that Davinci Resolve for Linux can read and edit.
#
#              This script heavily modifies the original in multiple ways: 
#              uses the more modern and flexible Avid DNxHR codec, preserves
#              audio and video resolution of the original video,
#              transcodes audio tracks to MP3 (libmp3lame) by default, and
#              selectively encodes all audio tracks in a video file
#
# TODO: Support batch conversion
# TODO: Add a flag to make "proxy" clips by allowing the user to specify their
#       resolution, and also use SQ DNxHR instead of HQ.
# TODO: Add a flag that specifies DV Studio, to skip the H264/H265 check.
# TODO: Use the MKV container instead if the video codec is AV1.
# TODO: Add a flag to use a more lossless audio codec (WAV pcm)
# Note: I would use libopus and flac, but ffmpeg doesn't support containerizing
#       them in mov. And DNxHR will not work in an MKV container.

SHORT_ARGS="h"
LONG_ARGS=help
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`

function list_help_info() {
  echo "Usage: davincivideo.sh [options] input_video"
  echo "    Options:"
  echo "    -h | --help            Lists the usage and flags that can be used"
  echo "Requires ffprobe and ffmpeg for usage."
}

while true; do 
  case "$1" in
    -h|--help) list_help_info
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *) 
      break
      ;;
  esac
done

# Check if an input file is provided
if [[ $# -eq 0 ]]; then
  list_help_info
  exit 0
fi

# Strip the file extension
destination="${1%.*}"
# Strip the path to get the name
input_file=${destination##*/}
# Get the output file name (same as input but with .mov extension)
output_file="$destination-T.mov"
echo $1

vtranscode_str="-c:v copy"

# Use ffprobe and grab the video's codec
ffprobe -hide_banner -loglevel warning -i "$1" -print_format ini -show_format -select_streams v:0 -show_entries stream=codec_name -sexagesimal -o metadata.tmp.txt

video_codec=$(grep "codec_name" metadata.tmp.txt)
video_codec=${video_codec:11}
# video_width=$(grep "width=" metadata.tmp.txt)
# video_width=${video_width:6}
# video_height=$(grep "height=" metadata.tmp.txt)
# video_height=${video_height:7}
# video_rfps=$(grep "r_frame_rate=" metadata.tmp.txt)
# video_rfps=${video_rfps:13}
# video_fps=$(awk "BEGIN { print $video_rfps }")

# Grab audio metadata
ffprobe -hide_banner -loglevel warning -i "$1" -print_format ini -show_format -select_streams a -show_entries stream=codec_name -sexagesimal -o metadata.tmp.txt

# Since there can be multiple audio tracks in a video file, separate all results into a list
audio_codecs=(`grep "codec_name" metadata.tmp.txt`)
i=0
tc=0 # boolean for tracking if current audio track was transcoded
tcr=0 # Boolean to check if ANY audio track was transcoded
input_str=""
map_str="-map 0:v"

# Due to ffmpeg limitations, we must split each transcoded audio track into their own file and merge them back
for line in "${audio_codecs[@]}"; do
  acodec="${line:11}"
  # DV4L doesn't support AAC, regardless of Free or Studio.
  # FFmpeg doesn't support Opus in mov.
  if [[ $acodec == "aac" || $acodec == "opus" ]]; then
    echo "    Transcoding Audio Track #$i"
    ffmpeg -y -hide_banner -loglevel warning -stats -i "$1" -map 0:a:$i -c:a libmp3lame "a$i.tmp.mp3"
    input_str="${input_str} -i a$i.tmp.mp3"
    tc=1
    tcr=1
  else
    echo "    Skipping Audio Track #$i"
    map_str="${map_str} -map 0:a:$i"
    tc=0
  fi
  i=$(( i+1 ))
  if (( tc == 1 )); then
    map_str="${map_str} -map $i"
  fi
done

# echo "CODEC: $video_codec, RESOLUTION: $video_width x $video_height @ $video_fps"
# echo "CODEC: $audio_codec"

video_transcode=0

# Is the video using a codec DV4L doesn't support?
if [[ $video_codec == "h264" || $video_codec == "h265" ]]; then
  video_transcode=1
  echo "    Transcoding Video"
else
  echo "    Video is already in an acceptable codec. Skipping"
fi

if (( video_transcode == 1 )); then
  vtranscode_str="-c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p"
fi

# Use ffmpeg to convert the MP4 file to MOV with the specified framerate
ffmpeg -hide_banner -loglevel warning -stats -i "$1" $input_str $vtranscode_str $map_str -f mov "$output_file"

echo "Conversion completed. Output file: $output_file"
echo "Cleaning temp files"
# Clean up temp files
rm metadata.tmp.txt
if (( tcr == 1 )); then
  rm a*.tmp.mp3
fi