#!/usr/bin/env bash

# Name: davincideliver.sh (davincimp4.sh)
# Author: Morxemplum, originally by Danie van der Merwe
# Depends on: ffmpeg
#
# Description: This is a shell script that takes exported DaVinci Resolve
#              renders and transcodes them into a deliverable video format.              

function list_help_info() {
  echo "Usage: davincideliver.sh [options] input_render"
  echo ""
  echo "General Options:"
  echo "    -h | --help            Lists the usage and flags that can be used."
  echo "    -o | --output    [dir] Allows the user to specify a custom directory to output"
  echo "                           transcoded media. By default, transcoded media will output to"
  echo "                           the same folder as their original counterpart"
  echo ""
  echo "Hardware Acceleration:"
  echo "    By default, this script will use software encoding to ensure the best compatibility."
  echo "    However, software encoding is slow, so hardware acceleration is needed to speed up"
  echo "    encoding. Below are a list of options to enable hardware acceleration based on your"
  echo "    GPU."
  echo ""
  echo "    --nvidia               Enables NVENC + CUDA hardware acceleration. NVIDIA GPUs only!"
  echo "    --vaapi                Enables VAAPI hardware acceleration. AMD and Intel GPUs only!"
  echo "    --vulkan               Enables Vulkan hardware acceleration. Cross-compatible, but is"
  echo "                           currently experimental. Requires a GPU that supports Vulkan"
  echo "                           1.3.274 or higher for H.264/265. 1.3.302 or higher for AV1."
  echo ""
  echo "    NOTE: AV1 is still a fairly new codec, so any hardware acceleration will require a"
  echo "    fairly recent GPU to achieve."
  echo ""
  echo "Requires ffmpeg for usage."
}

SHORT_ARGS="ho"
LONG_ARGS=help,output,nvidia,vaapi,vulkan
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`

OUTPUT_DEST=""
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
    # General options
    -h|--help) list_help_info
      exit 0
      ;;
    -o|--output)
      OUTPUT_DEST=$2
      shift 2
      ;;
    # Hardware Acceleration
    --nvidia)
      HARDWARE_ACC=1
      shift
      ;;
    --vaapi)
      HARDWARE_ACC=2
      shift
      ;;
    --vulkan)
      HARDWARE_ACC=3
      shift
      ;;
    # Default cases / end of options
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

hw_accel_flags=""
if (( HARDWARE_ACC == 1 )); then
  echo "Using NVENC acceleration"
  hw_accel_flags="-hwaccel cuda"
elif (( HARDWARE_ACC == 2 )); then
  echo "Using VAAPI acceleration"
  hw_accel_flags="-hwaccel vaapi"
elif (( HARDWARE_ACC == 3 )); then
  echo "Using Vulkan acceleration"
  echo "   WARNING: Vulkan acceleration is experimental."
  hw_accel_flags="-hwaccel vulkan"
elif (( HARDWARE_ACC != 0 )); then
  echo "Error: Invalid hardware acceleration value detected!"
  exit 1
else
  echo "Using software encoding"
fi

if (( HARDWARE_ACC != 0 )); then
  hw_accel_flags="${hw_accel_flags} -hwaccel_device 0" # If your GPU is somewhere else, change this
fi

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
    echo "   WARNING: AV1 on Vulkan acceleration is *highly* experimental. There is a high chance it will not transcode (properly) as there's no official specification."
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

# Software encoding is going to handling quality a bit more differently
video_quality_flags="-qp 15 -bf 2"
audio_flags="-codec:a aac -b:a 384k -r:a 48000"

# These are format flags that each do the following
# yadif (yet another deinterlacing format): Removes interlacing artifacts present in the video
# +cgop (closed group of pictures): This changes from open gop to closed gop. Websites like YouTube prefer this method
# pix_fmt: Pixel format. yuv420p will do the trick in most cases, unless you plan on doing HDR content or utilize better chroma subsampling
# TODO: Tailor the pixel format based on bit depth, and perhaps use a higher subsampling (4:2:2) or none when dealing with higher quality presets
# faststart: Puts most headers at the beginning of file, along with interleaving audio with video for better web performance
format_flags="-flags +cgop -movflags faststart"
if (( HARDWARE_ACC == 3 )); then
  # When using Vulkan hardware acceleration, you must use the vulkan pixel format, as it is not compatible with YUV.
  # In addition, a couple other flags are needed for vulkan acceleration, possibly reducing compatibility
  format_flags="${format_flags} -vf yadif,format=nv12,hwupload -pix_fmt vulkan"
else
  format_flags="${format_flags} -vf yadif -pix_fmt yuv420p"
fi


ffmpeg -hide_banner -loglevel warning -stats $hw_accel_flags -i "$1" $format_flags -codec:v $codec $video_quality_flags $audio_flags "$output_file"
 
echo "Conversion completed. Output file: $output_file"