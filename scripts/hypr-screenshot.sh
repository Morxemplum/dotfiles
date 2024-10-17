# Establish a destination and naming format
IMG="$(xdg-user-dir PICTURES)/Screenshots/$(date +'Screenshot %Y-%m-%d %H-%M-%S')"

# Use grim and slurp to capture a PNG of the image
grim -g "$(slurp -d)" -l 9 "$IMG.png"
# Convert to JPEG XL
magick convert "$IMG.png" -quality 80 "$IMG.jxl"
# Copy the PNG to clipboard (for compatibility reasons) and remove the png
wl-copy < "$IMG.png"
rm "$IMG.png"
