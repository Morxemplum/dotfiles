{ config, pkgs, ... }:

{
  # Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.sessionVariables.NIXOS_OZONE_WL = "1";
	environment.systemPackages = with pkgs; [
		# Essentials
		doas
		fastfetch
		floorp # Browser
		home-manager
		kitty # Terminal Emulator
		vim 
		
		# System commands
		lshw
		
		# Compatibility tools
		appimage-run
	];

  # Enable nix command and flakes for searching purposes
	nix.extraOptions = ''
		experimental-features = nix-command flakes 
	'';
}
