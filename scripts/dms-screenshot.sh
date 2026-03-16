#!/usr/bin/env bash

## This recreates my old hypr-screenshot script with DMS's screenshot utility.
## Less work needs to be done, but I still want my screenshots saved as JPEG
## XLs. Plus, DMS's screenshot utility offers slight QoL improvement over
## grim + slurp.

# Establish a destination
SCREENSHOTS_FOLDER="$(xdg-user-dir PICTURES)/Screenshots"
# Check if screenshots folder exists
if [ ! -d "$SCREENSHOTS_FOLDER" ]; then
  mkdir "$SCREENSHOTS_FOLDER"
  if [ ! -d "$SCREENSHOTS_FOLDER" ]; then
    echo "Failed to make screenshots folder. Insufficient permissions?"
    exit 1
  fi
fi

# Establish naming format
IMG="$(date +'Screenshot %Y-%m-%d %H-%M-%S')"

## TODO: Support the different modes from DMS's screenshot utility via command line args

SCRN_OUTPUT=$(dms screenshot -d $SCREENSHOTS_FOLDER --filename "$IMG.png" --no-notify) 
if [ -z "$SCRN_OUTPUT" ]; then
  echo "User aborted"
  exit 0
fi
# Convert to JPEG XL
magick convert "${SCREENSHOTS_FOLDER}/$IMG.png" -quality 80 "${SCREENSHOTS_FOLDER}/$IMG.jxl"
# Delete the PNG
rm "${SCREENSHOTS_FOLDER}/$IMG.png"
## Show the full path for debugging purposes. Make sure it's a proper path.
# echo "${SCREENSHOTS_FOLDER}/$IMG.jxl" 
# Display a custom notification message.
dms notify "Screenshot captured!" "Saved as ${SCREENSHOTS_FOLDER}/$IMG.jxl"