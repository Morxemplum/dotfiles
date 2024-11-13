{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Libs
    grim
    libnotify
    slurp
    wl-clipboard

    # Essentials
    cliphist
    dunst # Notification Daemon
    hyprcursor # Cursors for Hyprland
    hyprpaper # Wallpapers
	 	rofi-wayland # App launcher
    waybar
  ];
}