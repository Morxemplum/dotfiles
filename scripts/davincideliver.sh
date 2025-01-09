#!/usr/bin/env bash

# Name: davincideliver.sh (davincimp4.sh)
# Author: Morxemplum, originally by Danie van der Merwe
# Depends on: ffmpeg
#
# Description: This is a shell script that takes exported DaVinci Resolve
#              renders and transcodes them into a deliverable video format.
#
#              This script makes several major improvements over the original:
#              - Allows for easier switching between various methods of
#                hardware acceleration
#              - Supports more and newer hardware acceleration methods, such
#                as VAAPI and the experimental Vulkan acceleration
#              - Allows you to deliver with H.265 and AV1 codecs.
#              - Deinterlacing is optional, which can improve encoding speeds.
#              - Incorporates quality presets for quick and easy tuning.
#              - Or you can also use a constant bitrate (not recommended)
#              - You can opt out of AAC transcoding and preserve exported audio

function list_help_info() {
  echo "Usage: davincideliver.sh [options] input_render"
  echo ""
  echo "General Options:"
  echo "    -h | --help            Lists the usage and flags that can be used."
  echo "    -o | --output    [dir] Allows the user to specify a custom directory to output"
  echo "                           transcoded media. By default, transcoded media will output to"
  echo "                           the same folder as their original counterpart."
  echo "    -q | --quality  [0-10] Allows for you to easily tune the quality of the deliverable"
  echo "                           using calculated presets. A higher value will reduce quality"
  echo "                           for a lower file size. 0 will be visually lossless."
  echo "                           Default quality preset is 3."
  echo "    --overwrite  [yes|ask] Allows media to be retranscoded and overwrite previous copies."
  echo "                           yes will overwrite media automatically, ask will ask the user"
  echo "                           to overwrite for each existing transcode found."
  echo "    --preserve-audio       Disables audio transcoding to AAC, keeping the exported audio"
  echo "                           in the deliverable. Useful if you're really trying to lower"
  echo "                           file size or shipping with (near) lossless audio."
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
  echo "Video Codecs:"
  echo "    By default, this script uses H.264, as it's less computationally intensive and"
  echo "    the most compatible format across the web. But it does leave a bigger file size,"
  echo "    hence will also use more bandwidth. Below are options of more advanced codecs that"
  echo "    can lead to a smaller file size without losing quality."
  echo ""
  echo "    --hevc                 Uses the H.265 video codec. Twice as effective as H.264."
  echo "                           Has broader hardware support, but limited software support."
  echo "    --av1                  Uses the AV1 video codec. About twice as effective, and a"
  echo "                           tad more effective than H.265. Is limited to more recent"
  echo "                           hardware, but has better software support." 
  echo ""
  echo "Extras:"
  echo "    Most of the flags above should take care of most use cases. These are flags that"
  echo "    can help handle certain edge cases should they be needed. However, it is highly"
  echo "    recommended that you *do not* use these flags unless absolutely necessary."
  echo ""
  echo "    --deinterlace          Enables yadif, a library that will help remove interlacing"
  echo "                           from videos. Will slow down encoding, so only use it if you"
  echo "                           have renders with interlacing."
  echo "    --use-bitrate   [rate] Instead of using constant quality or constant rate factor"
  echo "                           which can fluctuate the amount of bits used, a constant"
  echo "                           bitrate is used to enforce quality (bits/s). This should"
  echo "                           ONLY be used if a hosting platform doesn't support"
  echo "                           constant quality. It is imprecise and doesn't net you a lot"
  echo "                           of savings."
  echo "                           (Using this option will ignore the quality presets flag)"
  echo ""
  echo "Requires ffmpeg for usage."
}

SHORT_ARGS="hoq"
LONG_ARGS=help,output,quality,overwrite,preserve-audio,nvidia,vaapi,vulkan,hevc,av1,deinterlace,use-bitrate
PARSED=`getopt --options $SHORT_ARGS --longoptions $LONG_ARGS --name "$0" -- "$@"`

HARDWARE_ACC=0 
OUTPUT_CODEC="h264"
OUTPUT_DEST=""
OVERWRITE=0 # 0 False; 1 True; 2 Ask
PRESERVE_AUDIO=0
QUALITY=3

DEINTERLACE=0
# Any non-zero value means constant bitrate will be used. Quality will be ignored
CONSTANT_BITRATE=0 

# get_hardware_flags()
# Takes a look at the given hardware acceleration and sets the appropriate flags
# Returns a string of the hardware acceleration flags
function get_hardware_flags() {
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
}

# get_video_codec()
# Based on hardware acceleration and chosen codec, choose the appropriate library.
# Returns the name of the library that follows the chosen codec with the corresponding acceleration
function get_video_codec() {
  if (( HARDWARE_ACC == 0 )); then
    # libx264 is default
    if [[ $OUTPUT_CODEC == "hevc" ]]; then
      codec="libx265"
    elif [[ $OUTPUT_CODEC == "av1" ]]; then
      codec="libsvtav1"
    fi
  else
    codec="${OUTPUT_CODEC}"
  fi

  if (( HARDWARE_ACC == 1 )); then
    codec="${codec}_nvenc"
  elif (( HARDWARE_ACC == 2 )); then
    codec="${codec}_vaapi"
  elif (( HARDWARE_ACC == 3 )); then
    codec="${codec}_vulkan"
    if [[ $OUTPUT_CODEC == "hevc" ]]; then
      echo "   ERROR: hevc_vulkan is currently broken at the moment. Please revert back to h264 until it is fixed."
      exit 1
    elif [[ $OUTPUT_CODEC == "av1" ]]; then
      echo "   WARNING: AV1 on Vulkan acceleration is *highly* experimental. There is a high chance it will not transcode (properly) as there's no official specification."
    fi
  fi
}

# calculate_video_quality()
# Based on hardware acceleration, codec, and a given quality preset, calculate an appropriate quality factor for the output video
# Returns a quantization factor for constant quality, along with the corresponding flag name for constant quality (it varies depending on the library)
function calculate_video_quality() {
  if [[ $CONSTANT_BITRATE != "0" ]]; then
    quality_name="b:v"
    quantization=$CONSTANT_BITRATE
    return 0
  fi
  if [[ $OUTPUT_CODEC == "h264" ]]; then
    quantization=$(awk "BEGIN { print int(11 + 4 * ${QUALITY}) }")
    if (( HARDWARE_ACC == 1 )); then
      quantization=$(awk "BEGIN { print int(18 + 3.3 * ${QUALITY}) }")
      quality_name="cq"
    elif (( HARDWARE_ACC == 2 || HARDWARE_ACC == 3 )); then
      quantization=$(awk "BEGIN { print int(18 + 3.3 * ${QUALITY}) }")
      quality_name="qp"
    fi
  elif [[ $OUTPUT_CODEC == "hevc" ]]; then
    quantization=$(awk "BEGIN { print int(14 + 3.7 * ${QUALITY}) }")
    if (( HARDWARE_ACC == 1 )); then
      quantization=$(awk "BEGIN { print int(22 + 2.9 * ${QUALITY}) }")
      quality_name="cq"
    elif (( HARDWARE_ACC == 2 || HARDWARE_ACC == 3 )); then
      quantization=$(awk "BEGIN { print int(22 + 2.9 * ${QUALITY}) }")
      quality_name="qp"
    fi
  elif [[ $OUTPUT_CODEC == "av1" ]]; then
    quantization=$(awk "BEGIN { print int(16 + 3.5 * ${QUALITY}) }")
    # I don't have a NVIDIA card that supports AV1 hardware encoding, so these values are just estimates.
    if (( HARDWARE_ACC == 1 )); then
      quantization=$(awk "BEGIN { print int(23 + 2.8 * ${QUALITY}) }")
      quality_name="cq"
    elif (( HARDWARE_ACC == 2 || HARDWARE_ACC == 3 )); then
      quantization=$(awk "BEGIN { print int(23 + 2.8 * ${QUALITY}) }")
      quality_name="qp"
    fi
  fi
}

# get_format_flags()
# Based on hardware acceleration and quality presets, it will fine tune various video formatting flags to further set the quality of the video, remove defects, and improve viewing experience
# Returns a string of various formatting flags
function get_format_flags() {
  # +cgop (closed group of pictures): This changes from open gop to closed gop. Websites like YouTube prefer this method
  format_flags="-flags +cgop"
  if (( DEINTERLACE == 1 )); then
    # yadif (yet another deinterlacing format): Removes interlacing artifacts present in the video
    format_flags="${format_flags} -vf yadif"
  fi
  if (( HARDWARE_ACC == 3 )); then
    # When using Vulkan hardware acceleration, you must use the vulkan pixel format, as it is not compatible with YUV.
    # In addition, a couple other flags are needed for vulkan acceleration, possibly reducing compatibility
    if (( DEINTERLACE == 1 )); then
      format_flags="${format_flags},format=nv12,hwupload -pix_fmt vulkan"
    else
      format_flags="${format_flags} -vf format=nv12,hwupload -pix_fmt vulkan"
    fi
  else
    # DNxHR HQ only goes up to 4:2:2 subsampling. However, NVENC will not accept yuv422. So no subsampling is done instead.
    chroma="444" 
    if (( QUALITY >= 3 )); then
      chroma="420"
    fi
    # pix_fmt: Pixel format. This is where chroma subsampling and bit-depth are involved.
    # TODO: If you wanna add HDR support, then append a suffix "10le" to the pix_fmt
    format_flags="${format_flags} -pix_fmt yuv${chroma}p"
  fi
  if [[ $file_container == "mp4" ]]; then
    # faststart: Puts most headers at the beginning of file, along with interleaving audio with video for better web performance
    # This is needed for the mp4 container, but not for the mkv container
    format_flags="${format_flags} -movflags faststart"
  fi
}

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

# find_existing_output(output_file)
# Checks to see if the video has already been transcoded, and handles the behavior according to user preferences.
# If the user specifies overwriting files, a string with the ffmpeg overwrite flag is returned
function find_existing_output() {
  if [[ -f $1 ]]; then
    if (( OVERWRITE == 0 )); then
      echo "    Transcoded output already exists. Skipping."
      # TODO: When implementing batch conversion, change this to just end this conversion, instead of terminating the script
      exit 0
    elif (( OVERWRITE == 1 )); then
      echo "    Transcoded output already exists. Overwriting."
      overwrite_str="-y"
    fi
    # As for 2, we don't need to do anything as ffmpeg will handle the prompt for us
  fi
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
    -q|--quality)
      QUALITY=$2
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
    --preserve-audio)
      PRESERVE_AUDIO=1
      shift
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
    # Video codecs
    --hevc)
      OUTPUT_CODEC="hevc"
      shift
      ;;
    --av1)
      OUTPUT_CODEC="av1"
      shift
      ;;
    # Extras
    --deinterlace)
      DEINTERLACE=1
      shift
      ;;
    --use-bitrate)
      CONSTANT_BITRATE=$2
      echo "Using Constant Bitrate (Quality Presets will be ignored)"
      shift 2
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

# Configure Hardware acceleration settings
hw_accel_flags=""
get_hardware_flags

# Select the appropriate codec
codec="libx264"
get_video_codec

video_quality_flags="-bf 2"
audio_flags="-c:a aac -r:a 48000"
if (( PRESERVE_AUDIO == 1 )); then
  echo "AAC Transcoding Disabled"
  audio_flags="-c:a copy"
fi

# Calculate Quantization values. They vary depending on the codec, and also the specific implementations
quantization=0
quality_name="crf"
calculate_video_quality
video_quality_flags="${video_quality_flags} -${quality_name} ${quantization}"

file_container="mp4"
# AV1 can not be contained by mp4. I'm choosing to switch to Matroska instead of webm.
if [ $OUTPUT_CODEC == "av1" ]; then
  file_container="mkv"
fi

get_format_flags

# BEGIN VIDEO CONVERSION
echo $1
 
output_file=""
format_file_name "$1"

output_file="${output_file}.$file_container"
overwrite_str=""
find_existing_output "$output_file"

ffmpeg $overwrite_str -hide_banner -loglevel warning -stats $hw_accel_flags -i "$1" $format_flags -codec:v $codec $video_quality_flags $audio_flags "$output_file"
 
echo "Conversion completed. Output file: $output_file"