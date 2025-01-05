{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { 
    config.allowUnfree = true;
  };
in
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
		
		# Nix tools
		nix-prefetch-github
		
		# Useful libs and tools
		gdb
		htop 
		imagemagick 
		inotify-tools
		killall 
		lshw
		pstree
		python3Full # This is solely for the purpose of running scripts.
		
		# Compatibility tools
		appimage-run
		distrobox

		# Packages I Maintain
		unstable.mcpelauncher-client
		unstable.mcpelauncher-ui-qt
	];

  # Enable nix command and flakes for searching purposes
	nix.extraOptions = ''
		experimental-features = nix-command flakes 
	'';

	# Enable flatpak
	services.flatpak.enable = true;

	# Enable support for Xbox controllers
	hardware.xone.enable = true;
	hardware.xpadneo.enable = true;

	# Enable common container config files in /etc/containers
	virtualisation.containers.enable = true;
	virtualisation = {
	  podman = {
	    enable = true;
	    # Create a `docker` alias for podman, to use it as a drop-in replacement
	    dockerCompat = true;
	    # Required for containers under podman-compose to be able to talk to each other.
	    defaultNetwork.settings.dns_enabled = true;
	  };
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "24.11"; # Did you read the comment?
}
