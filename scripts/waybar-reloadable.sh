#!/bin/bash

# Add any waybar files so they can be watched
CONFIG_FILES="$HOME/dotfiles/config/waybar/config $HOME/dotfiles/config/waybar/style.css"

# If this script stops, kill waybar
trap "killall waybar" EXIT

# Since waybar doesn't have hot reloading built in, this script watches for changes using inotify and reloads when any of our configs have been modified
while true; do
    waybar &
    inotifywait -e create,modify $CONFIG_FILES
    killall waybar
done
