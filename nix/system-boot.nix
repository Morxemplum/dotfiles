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

	# Enable the X11 windowing system.
	services.xserver.enable = true;
	services.displayManager.ly.enable = true;
	# Enable the GNOME Desktop Environment.
	services.xserver.desktopManager.gnome.enable = true;
	# Enable the Hyprland Window Manager.
	programs.hyprland.enable = true;
}