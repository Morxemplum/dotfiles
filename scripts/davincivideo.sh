#!/usr/bin/env bash

# Name: davincivideo.sh
# Author: Morxemplum, originally by Danie van der Merwe
# Depends on: ffprobe, ffmpeg
# Description: This is a shell script that takes videos that are using
#              unsupported codecs and transcodes them into production ready 
#              codecs that Davinci Resolve for Linux can read and edit.
#
#              This script completely transforms the original in multiple ways: 
#              - Uses the more modern and flexible Avid DNxHR codec
#              - Preserves audio and video resolution of the original video
#              - Has a quickhand method of generating proxy media
#              - Transcodes audio tracks to MP3 (libmp3lame) by default
#              - Selectively encodes all audio tracks in a video file
#
# TODO: Support batch conversion
# Note: I would use libopus and flac, but ffmpeg doesn't support containerizing
#       them in mov. And DNxHR will not work in an MKV container.

SHORT_ARGS="hop"
LONG_ARGS=help,output,overwrite,proxy,studio,raw-audio
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`

# Program variables
OUTPUT_DEST=""
OVERWRITE=0 # 0 False; 1 True; 2 Ask
PROXY=0
PROXY_SCALE=100
RAW_AUDIO=0
STUDIO=0

function list_help_info() {
  echo "Usage: davincivideo.sh [options] input_video"
  echo ""
  echo "Options:"
  echo "    -h | --help            Lists the usage and flags that can be used."
  echo "    -o | --output    [dir] Allows the user to specify a custom directory to output"
  echo "                           transcoded media. By default, transcoded media will output to"
  echo "                           the same folder as their original counterpart"
  echo "    -p | --proxy   [scale] Allows video to be transcoded to a resolution smaller than the"
  echo "                           original, and downgrades to DNxHR_SQ. Useful for generating"
  echo "                           proxy media that is easier to process and has smaller file size."
  echo "                           Scale is represented as a percentage, acceptable values 10 - 100" 
  echo "    --overwrite  [yes|ask] Allows media to be retranscoded and overwrite previous copies."
  echo "                           yes will overwrite media automatically, ask will ask the user"
  echo "                           to overwrite for each existing transcode found."
  echo "    --raw-audio            Instead of transcoding audio to mp3, raw PCM will be used."
  echo "                           Use if you want no/minimal loss in audio quality, but will"
  echo "                           increase file size. (pcm_s16le)"
  echo "    --studio               Asserts that the user is using DaVinci Resolve Studio, skipping"
  echo "                           transcoding for any videos using h264/h265."
  echo "                           (WARNING: Only use this if you are limited on time/disk space."
  echo "                           DaVinci Resolve has a harder time processing these codecs.)"
  echo ""
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
    -p|--proxy)
      PROXY=1
      PROXY_SCALE=$2
      shift 2
      ;;
    --overwrite)
      lower=$(awk "BEGIN { print tolower(\"$2\") }")
      if [[ $lower == "y" || $lower == "yes" ]]; then
        OVERWRITE=1
      elif [[ $lower == "a" || $lower == "ask" ]]; then
        OVERWRITE=2
      else
        echo "ERROR: Invalid/missing input for overwrite flag"
        exit 1
      fi
      shift 2
      ;;
    --raw-audio)
      RAW_AUDIO=1
      shift
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
file_container="mov"

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

# Get the output file name (File extension will be added later)
output_file="$DESTINATION-T"

video_metadata="codec_name"
if (( PROXY == 1 )); then
  # Sanity checks on the Proxy Scale
  if !(( PROXY_SCALE )); then
    echo "ERROR: Proxy scale ($PROXY_SCALE) is not a number!"
    exit 1
  fi
  if (( PROXY_SCALE < 10 || PROXY_SCALE > 100 )); then
    echo "ERROR: Proxy scale is outside of acceptable range (10 - 100)"
    exit 1
  elif (( PROXY_SCALE != 100 )); then
    video_metadata="${video_metadata},width,height"
  fi
  # Get the actual decimal point
  PROXY_SCALE=$(awk "BEGIN { print $PROXY_SCALE/100 }")
  output_file="${output_file}P"
fi

echo $1

vtranscode_str="-c:v copy"
video_transcode=0
switch_container=0

# Use ffprobe and grab the necessary metadata
ffprobe -hide_banner -loglevel warning -i "$1" -print_format ini -show_format -select_streams v:0 -show_entries stream=$video_metadata -sexagesimal -o metadata.tmp.txt

video_codec=$(grep "codec_name" metadata.tmp.txt)
video_codec=${video_codec:11}

if [[ $PROXY == "1" && $PROXY_SCALE != "1" ]]; then
  video_width=$(grep "width=" metadata.tmp.txt)
  video_width=${video_width:6}
  video_height=$(grep "height=" metadata.tmp.txt)
  video_height=${video_height:7}

  proxy_width=$(awk "BEGIN { print int($video_width * $PROXY_SCALE) }")
  proxy_height=$(awk "BEGIN { print int($video_height * $PROXY_SCALE) }")

  # echo "CODEC: $video_codec, RESOLUTION: $video_width x $video_height, PROXY RESOLUTION: $proxy_width x $proxy_height"
fi

# Is the video using a codec DV4L doesn't support?
if [[ ($video_codec == "h264" || $video_codec == "h265") && $STUDIO == "0" ]]; then
  video_transcode=1
  echo "    Video needs transcoding"
# Free codecs (like VP9 and AV1) are not compatible with MOV, so if we must preserve that codec, then we need to switch the container
elif [[ $video_codec == "vp9" || $video_codec == "av1" ]]; then
  echo "    \"Free\" codec detected ($video_codec). Switching QuickTime to Matroska"
  # TODO: When adding a force transcode flag, recommend people to use this flag due to how demanding these codecs are
  switch_container=1
else
  echo "    Video is already in an acceptable codec"
fi

# TODO: Apply proxy scaling to videos that don't meet the criteria? Though this would involve having to learn various quirks of codecs.
if (( video_transcode == 1 )); then
  QUALITY_PRESET="dnxhr_hq"
  if (( PROXY == 1 )); then
    QUALITY_PRESET="dnxhr_sq"
  fi
  vtranscode_str="-c:v dnxhd -profile:v $QUALITY_PRESET -pix_fmt yuv422p"
  if [[ $PROXY == "1" && $PROXY_SCALE != "1" ]]; then
    echo "    Proxy Resolution: ${proxy_width}x${proxy_height}"
    vtranscode_str="${vtranscode_str} -s ${proxy_width}x${proxy_height}"
  fi
fi

if (( switch_container == 1 )); then
  file_container="mkv"
fi

output_file="${output_file}.$file_container"

# Check if the transcoded video already exists
overwrite_str=""
if [ -f $output_file ]; then
  if (( OVERWRITE == 0 )); then
    echo "    Transcoded output already exists. Skipping."
    # TODO: When implementing batch conversion, change this to just end this conversion, instead of terminating the script
    rm metadata.tmp.txt
    exit 0
  elif (( OVERWRITE == 1 )); then
    echo "    Transcoded output already exists. Overwriting."
    overwrite_str="-y"
  fi
  # As for 2, we don't need to do anything as ffmpeg will handle the prompt for us
fi

# Grab audio metadata
ffprobe -hide_banner -loglevel warning -i "$1" -print_format ini -show_format -select_streams a -show_entries stream=codec_name -sexagesimal -o metadata.tmp.txt

# Since there can be multiple audio tracks in a video file, separate all results into a list
audio_codecs=(`grep "codec_name" metadata.tmp.txt`)
i=0
tc=0 # boolean for tracking if current audio track was transcoded
tcr=0 # Boolean to check if ANY audio track was transcoded
input_str="-i $1"
map_str="-map 0:v"

# Due to ffmpeg limitations, we must split each transcoded audio track into their own file and merge them back
for line in "${audio_codecs[@]}"; do
  acodec="${line:11}"
  # DV4L doesn't support AAC or Ogg Vorbis, regardless of Free or Studio.
  # FFmpeg doesn't support Opus in mov.
  if [[ ($acodec == "aac" || $acodec == "vorbis") || ($acodec == "opus" && $file_container == "mov") ]]; then
    echo "    Transcoding Audio Track #$i"
    if (( RAW_AUDIO == 1 )); then
      ffmpeg -y -hide_banner -loglevel warning -stats -i "$1" -map 0:a:$i -c:a pcm_s16le "a$i.tmp.wav"
      input_str="${input_str} -i a$i.tmp.wav"
    else
      ffmpeg -y -hide_banner -loglevel warning -stats -i "$1" -map 0:a:$i -c:a libmp3lame "a$i.tmp.mp3"
      input_str="${input_str} -i a$i.tmp.mp3"
    fi
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

# Use ffmpeg to convert the MP4 file to MOV with the specified framerate
ffmpeg $overwrite_str -hide_banner -loglevel warning -stats $input_str $vtranscode_str -c:a copy $map_str "$output_file"

echo "Conversion completed. Output file: $output_file"
echo "Cleaning temp files"
# Clean up temp files
rm metadata.tmp.txt
if (( tcr == 1 )); then
  if (( RAW_AUDIO == 1 )); then
    rm a*.tmp.wav
  else
    rm a*.tmp.mp3
  fi
fi