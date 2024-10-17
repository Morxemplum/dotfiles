IMG="$(xdg-user-dir PICTURES)/Screenshots/$(date +'Screenshot %Y-%m-%d %H-%M-%S')"

grim -g "$(slurp -d)" -l 9 "$IMG.png"
magick convert "$IMG.png" -quality 80 "$IMG.jxl"
wl-copy < "$IMG.png"
rm "$IMG.png"
