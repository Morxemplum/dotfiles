#!/usr/bin/env bash

# Name: fix-xwayland-scaling.sh
# Author: Morxemplum
# Description: This is a startup shell script that is used to help XWayland
# applications scale themselves properly to my HiDPI monitors. This is useful
# for window managers / desktop environments that don't properly support X
# applications scaling properly.

export GDK_SCALE=2
export GDK_DPI_SCALE=1
# Fix the cursor size
export XCURSOR_SIZE=36 # 24 * 1.5

DESIRED_DPI="144" # 96 * 1.5
echo "Xft.dpi: ${DESIRED_DPI}" | xrdb -merge

if [ -r "${HOME}/.Xresources" ] && command -v xrdb >/dev/null 2>&1; then
	xrdb -merge "${HOME}/.Xresources"
fi

xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
