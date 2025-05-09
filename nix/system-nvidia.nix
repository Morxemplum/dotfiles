{ config, pkgs, ... }:

# In an ideal future, what I am hoping for is that I will be using NVK for most
# of my operations, and only have to use the proprietary drivers for programs
# that rely on CUDA acceleration (e.g. Davinci Resolve)

{
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  services.xserver.videoDrivers = [ "nvidia" ];
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};
	hardware.nvidia = {
  	package = config.boot.kernelPackages.nvidiaPackages.stable;
    # NVIDIA now recommends newer cards use the open drivers
    # https://developer.nvidia.com/blog/nvidia-transitions-fully-towards-open-source-gpu-kernel-modules/
  	open = true; 
  	modesetting.enable = true;

    # nvidia.NVreg_PreserveVideoMemoryAllocations is required for this to work properly.
    # FIXME: Sometimes, the system will re-suspend (and will often brick the session) shortly after resuming. This doesn't happen too often, but it is annoying when it happens.
    powerManagement.enable = true;
  };
}