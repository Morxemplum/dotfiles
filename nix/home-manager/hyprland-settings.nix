{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    hyprpaper # Wallpapers
	 	rofi-wayland # App launcher
  ];
}