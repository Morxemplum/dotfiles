{ config, pkgs, ... }:

# In an ideal future, what I am hoping for is that I will be using NVK for most
# of my operations, and only have to use the proprietary drivers for programs
# that rely on CUDA acceleration (e.g. Davinci Resolve)

let
  unstable-pkgs = import <nixos-unstable> {
    config.allowUnfree = true;
  };
in
{
  services.xserver.videoDrivers = [ "nvidia" ];
	hardware.opengl = {
		enable = true;
		driSupport32Bit = true;
	};
	hardware.nvidia = {
		# The unstable Nvidia drivers have plenty of improvements stable doesn't have (e.g Explicit Sync)
    # This will be reverted when upgrading to 24.11
  	package = unstable-pkgs.linuxPackages.nvidiaPackages.latest;
    # NVIDIA now recommends newer cards use the open drivers
    # https://developer.nvidia.com/blog/nvidia-transitions-fully-towards-open-source-gpu-kernel-modules/
  	open = true; 
  	modesetting.enable = true;

    # Power Management does not work on my system, and I don't have hybrid graphics.
    # powerManagement.enable = true;
  };
}