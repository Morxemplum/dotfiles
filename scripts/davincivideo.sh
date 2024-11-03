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
# TODO: Use the MKV container instead if the video codec is AV1.
# TODO: Add a flag to use a more lossless audio codec (WAV pcm)
# Note: I would use libopus and flac, but ffmpeg doesn't support containerizing
#       them in mov. And DNxHR will not work in an MKV container.

SHORT_ARGS="ho"
LONG_ARGS=help,output,studio
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`

# Program variables
STUDIO=0
OUTPUT_DEST=""

function list_help_info() {
  echo "Usage: davincivideo.sh [options] input_video"
  echo "    Options:"
  echo "    -h | --help            Lists the usage and flags that can be used."
  echo "    -o | --output          Allows the user to specify a custom directory to output"
  echo "                           transcoded media. By default, transcoded media will output to"
  echo "                           the same folder as their original counterpart"
  echo "    --studio               Asserts that the user is using DaVinci Resolve Studio, skipping"
  echo "                           transcoding for any videos using h264/h265."
  echo "                           (WARNING: Only use this if you are limited on time/disk space."
  echo "                           DaVinci Resolve has a harder time processing these codecs.)"
  echo "Requires ffprobe and ffmpeg for usage."
}

while true; do 
  case "$1" in
    -h|--help) list_help_info
      exit 0
      ;;
    -o|--output)
      OUTPUT_DEST=$2
      shift 2
      ;;
    --studio)
      STUDIO=1
      shift
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
DESTINATION="${1%.*}"
# Strip the path to get the name
input_file=${DESTINATION##*/}

# Check if an output destination was specified, and if it exists.
if [ "$OUTPUT_DEST" != "" ]; then
  OUTPUT_DEST=${OUTPUT_DEST%/}
  echo "Output Directory: $OUTPUT_DEST"
  if [ ! -d "$OUTPUT_DEST" ]; then
	  echo "    Output directory does not exist. Creating."
	  mkdir "$OUTPUT_DEST"
	  if [ ! -d "$OUTPUT_DEST" ]; then
		  echo "    Failed to make output directory. Insufficient permissions?"
		  exit 1
	  fi
  fi
  DESTINATION="$OUTPUT_DEST/$input_file"
fi

# Get the output file name (same as input but with .mov extension)
output_file="$DESTINATION-T.mov"
echo $1

vtranscode_str="-c:v copy"
video_transcode=0

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

# Is the video using a codec DV4L doesn't support?
if [[ ($video_codec == "h264" || $video_codec == "h265") && $STUDIO == "0" ]]; then
  video_transcode=1
  echo "    Video needs transcoding"
else
  echo "    Video is already in an acceptable codec"
fi

if (( video_transcode == 1 )); then
  vtranscode_str="-c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p"
fi

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

# Use ffmpeg to convert the MP4 file to MOV with the specified framerate
ffmpeg -hide_banner -loglevel warning -stats -i "$1" $input_str $vtranscode_str $map_str -f mov "$output_file"

echo "Conversion completed. Output file: $output_file"
echo "Cleaning temp files"
# Clean up temp files
rm metadata.tmp.txt
if (( tcr == 1 )); then
  rm a*.tmp.mp3
fi