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
IMG="$SCREENSHOTS_FOLDER/$(date +'Screenshot %Y-%m-%d %H-%M-%S')"

# Use grim and slurp to capture a PNG of the image
grim -g "$(slurp -d)" -l 9 "$IMG.png"
# Convert to JPEG XL
magick convert "$IMG.png" -quality 80 "$IMG.jxl"
# Copy the PNG to clipboard (for compatibility reasons) and remove the png
wl-copy < "$IMG.png"
rm "$IMG.png"
