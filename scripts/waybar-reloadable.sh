#!/usr/bin/env bash

if [[ ! -d "$HOME/.config/waybar" ]]; then
	echo -e "\\nERROR: Missing waybar folder. Make sure you have your config and style loaded."
	exit 1
fi

if [[ ! -f "$HOME/.config/waybar/config" ]]; then
	echo -e "\\nERROR: Missing waybar config."
	exit 1
fi

if [[ ! -f "$HOME/.config/waybar/style.css" ]]; then
	echo -e "\\nERROR: Missing waybar CSS stylesheet."
	exit 1
fi

# Add any waybar files so they can be watched
CONFIG_FILES="$HOME/dotfiles/config/waybar/config $HOME/dotfiles/config/waybar/style.css"

if ! command -v trap > /dev/null ; then
	echo -e "\\nERROR: \"trap\" command not found"
	exit 1
fi

if ! command -v inotifywait > /dev/null ; then
	echo -e "\\nERROR: \"inotify-tools\" not found"
	exit 1
fi

if ! command -v killall > /dev/null ; then
	echo -e "\\nERROR: \"killall\" not found"
	exit 1
fi

# If this script stops, kill waybar
trap "killall waybar" EXIT

# Since waybar doesn't have hot reloading built in, this script watches for changes using inotify and reloads when any of our configs have been modified
while true; do
    waybar &
    inotifywait -e create,modify $CONFIG_FILES
    killall waybar
done
