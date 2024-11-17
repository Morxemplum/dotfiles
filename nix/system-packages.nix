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
		
		# Useful libs and tools
		htop 
		imagemagick 
		inotify-tools
		killall 
		lshw
		pstree
		
		# Compatibility tools
		appimage-run
		distrobox
	];

  # Enable nix command and flakes for searching purposes
	nix.extraOptions = ''
		experimental-features = nix-command flakes 
	'';

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
}
