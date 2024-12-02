# Welcome To My Dotfiles

This repository aims to serve all my go-to configurations. This includes Nix configuration files, various app configurations, theming, and useful shell scripts that are either tightly integrated with my setup, or aren't significant enough to warrant their own repository.

You are more than welcome to borrow any of my configurations for your own set ups.

## Synopsis of my setup

This dotfiles is mainly tailored for NixOS 24.11 using both the GNOME desktop environment, alongside the Hyprland window manager. There is additional configuration for NVIDIA drivers, primarily tailored for a smooth Wayland experience.

### GNOME

Most of my GNOME settings are declared through `dconf`, allowing for easy deployment. GNOME related packages, including extensions, and settings are all declared in a separate file.

The following extensions are included in my set up:
* [AppIndicator](https://extensions.gnome.org/extension/615/appindicator-support/)
* [Blur My Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
* [Dock From Dash](https://extensions.gnome.org/extension/4703/dock-from-dash/)

Other GNOME related packages include:
* dconf-editor
* gnome-tweaks

### Hyprland

All configuration related to hyprland are in .conf files, which you'll find in the `config/hypr` folder. Main utilities include hyprpaper, waybar, and rofi-wayland. There is also a hyprcursor theme that is based my own [Posy's Cursor (Scalable)](https://github.com/Morxemplum/posys-cursor-scalable) remade cursors.

#### Screenshots

A [custom screenshotting utility](scripts/hypr-screenshot.sh) uses grim and slurp, plus ImageMagick to transcode the image into JPEG XL for storage and wl-clipboard to copy in the clipboard for convenience and compatibility purposes.

#### Waybar

With a custom theme that vaguely represents GNOME + macOS, my waybar configuration combines both form and functionality for every day usage, while looking nice and clean. In addition, it also utilizes [a script](scripts/waybar-reloadable.sh) allowing for hot-reloading when tweaking the settings.

#### Other Utilities

* Dunst - *Notification Daemon*
* Cliphist - *Clipboard History*