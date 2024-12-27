{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { 
    config.allowUnfree = true;
  };
in
{
  programs.alvr = {
    enable = true;
    # TODO: Completely switch VR applications. SteamVR immediately crashes when my headset tries to connect.
    package = unstable.alvr;
    openFirewall = true;
  };
}