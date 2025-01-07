#!/usr/bin/env bash

# Name: davincideliver.sh (davincimp4.sh)
# Author: Morxemplum, originally by Danie van der Merwe
# Depends on: ffprobe, ffmpeg
#
# Description: This is a shell script that takes exported DaVinci Resolve
#              renders and transcodes them into a deliverable video format.              

function list_help_info() {
  echo "Usage: davincideliver.sh [options] input_render"
  echo ""
  echo "Options:"
  echo "    -h | --help            Lists the usage and flags that can be used."
  echo "    -o | --output    [dir] Allows the user to specify a custom directory to output"
  echo "                           transcoded media. By default, transcoded media will output to"
  echo "                           the same folder as their original counterpart"
  echo ""
  echo "Requires ffmpeg for usage."
}

SHORT_ARGS="ho"
LONG_ARGS=help,output
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`

OUTPUT_DEST=""
# TODO: Set this value based on what flag the user passes in
# HARDWARE_ACC has a different range of values depending on what the user chooses (based on their hardware)
# 0 = Software Encoding (No hardware encoding)
# 1 = NVIDIA NVENC + CUDA
# 2 = VAAPI (AMD + Intel)
# 3 = Vulkan (Cross compatible with all GPUs, experimental)
HARDWARE_ACC=0 
# TODO: Expand this to support H265 and AV1
OUTPUT_CODEC="h264"

# format_file_name(input_file_name)
# Formats the input file name to match the file path and naming convention of the output file
# Returns the output file name
function format_file_name() {
  # Strip the file extension
  DESTINATION="${1%.*}"
  # Strip the path to get the name
  input_file=${DESTINATION##*/}

  if [ "$OUTPUT_DEST" != "" ]; then
    DESTINATION="$OUTPUT_DEST/$input_file"
  fi

  # Return the output file name (File extension will be added later)
  output_file="$DESTINATION-D"
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
fi

# BEGIN VIDEO CONVERSION

echo $1
 
output_file=""
format_file_name "$1"

file_container="mp4"
if [ $OUTPUT_CODEC == "av1" ]; then
  file_container="mkv"
fi

# TODO: Add overwriting flag
output_file="${output_file}.$file_container"
# overwrite_str=""
# find_existing_output $output_file

# TODO: Add quality presets that will streamline this process
# Option in Video: FFmpeg command with hardware acceleration and encoding parameters
# For a higher bitrate try changing -qp 15 to -qp 10

hw_accel_flags="-hwaccel"

codec="libx264"
if [[ $OUTPUT_CODEC == "h264" && $HARDWARE_ACC -ne 0 ]]; then
  if (( HARDWARE_ACC == 1 )); then
    codec="h264_nvenc"
  elif (( HARDWARE_ACC == 2 )); then
    codec="h264_vaapi"
  else
    codec="h264_vulkan"
  fi
elif [[ $OUTPUT_CODEC == "h265" ]]; then
  codec="libx265"
  if (( HARDWARE_ACC == 1 )); then
    codec="hevc_nvenc"
  elif (( HARDWARE_ACC == 2 )); then
    codec="hevc_vaapi"
  elif (( HARDWARE_ACC == 3 )); then
    codec="hevc_vulkan"
  fi
elif [[ $OUTPUT_CODEC == "av1" ]]; then
  codec="libsvtav1"
  if (( HARDWARE_ACC == 1 )); then
    codec="av1_nvenc"
  elif (( HARDWARE_ACC == 2 )); then
    codec="av1_vaapi"
  elif (( HARDWARE_ACC == 3 )); then
    codec="av1_vulkan"
  fi
fi

if (( HARDWARE_ACC == 1 )); then
  hw_accel_flags="${hw_accel_flags} cuda"
elif (( HARDWARE_ACC == 2 )); then
  hw_accel_flags="${hw_accel_flags} vaapi"
elif (( HARDWARE_ACC == 3 )); then
  hw_accel_flags="${hw_accel_flags} vulkan"
elif (( HARDWARE_ACC != 0 )); then
  echo "Error: Invalid hardware acceleration value detected!"
  exit 1
fi

hw_accel_flags="${hw_accel_flags} -hwaccel_device 0" # If your GPU is somewhere else, change this

# These are format flags that each do the following
# yadif (yet another deinterlacing format): Removes any interlacing artifacts that may be present in the video
# +cgop (closed group of pictures): This changes from open gop to closed gop. This was removed as we are done editing the video and don't need to edit it anymore
# TODO: Perhaps add a flag to enable cgop
# pix_fmt: Pixel format. yuv420p will do the trick in most cases, unless you plan on doing HDR content or utilize better chroma subsampling
# TODO: Tailor the pixel format based on bit depth, and perhaps use a higher subsampling (4:2:2) or none when dealing with higher quality presets
format_flags="-vf yadif -pix_fmt yuv420p"

ffmpeg $hw_accel_flags_nvidia -i "$1" $format_flags -codec:v h264_nvenc -qp 15 -bf 2 -codec:a aac -strict -2 -b:a 384k -r:a 48000 -movflags faststart "$output_file"
 
# Another Nvidia option
# ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -i "$input_file.mov" -c:a copy -c:v h264_nvenc -b:v 10M -fps_mode passthrough "$output_file"
 
# Non Nvidia option
# ffmpeg -i "$input_file.mov" -vf yadif -codec:v libx264 -crf 1 -bf 2 -flags +cgop -pix_fmt yuv420p -codec:a aac -strict -2 -b:a 384k -r:a 48000 -movflags faststart "$output_file"
 
echo "Conversion completed. Output file: $output_file"