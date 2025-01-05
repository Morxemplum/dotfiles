{ config, pkgs, ... }:

{
	boot.loader = {
		systemd-boot.enable = false;
		efi = {
			canTouchEfiVariables = true;
		};
		grub = {
    		devices = [ "nodev" ];
    		enable = true;
    		efiSupport = true;
    		useOSProber = true;
    	};
	};

	boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];
	boot.supportedFilesystems = [ "ntfs" ];
}