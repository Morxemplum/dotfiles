{ config, pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };
}