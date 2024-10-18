{ config, pkgs, lib, ... }:

let
	settings = import ./user-settings.nix;
in
{
	# Setup
	programs.home-manager.enable = true;
	home.username = settings.USER_NAME;
	home.homeDirectory = settings.HOME_DIR;
	home.stateVersion = "24.05";
	
	# Packages
	nixpkgs.config.allowUnfree = true;
	home.packages = with pkgs; [
	  	armcord
	  	gimp
	  	localsend
	  	mpv
	  	thunderbird
	  	vscodium
	  	
	  	# CLI Utilities
	  	ffmpeg
	  	git
	  	yt-dlp
	  	
	  	# Gaming
	  	
	  	# GNOME Stuff
	  	dconf
	  	gnome.dconf-editor
	  	gnome.gnome-tweaks
	  	gnomeExtensions.appindicator
	  	gnomeExtensions.blur-my-shell
	  	gnomeExtensions.dock-from-dash
	  	
	  	# Theming
	  	posy-cursors
  	];
	
	# GNOME Tweaking
	dconf.settings = {
		"org/gnome/desktop/interface" = {
			cursor-size = 32;
			cursor-theme = "Posy_Cursor_Black_125_175";
		};
		"org/gnome/mutter" = {
			dynamic-workspaces = true;
			edge-tiling = true;
			experimental-features = [ "scale-monitor-framebuffer" ];
		};
		"org/gnome/settings-daemon/plugins/power" = {
			# NVIDIA + Wayland has issues when recovering from sleep, so it has to be turned off
			# Hopefully this will be fixed
			sleep-inactive-ac-type = "nothing";
		};
		"org/gnome/shell" = {
			disable-user-extensions = false;
			enabled-extensions = [
				"appindicatorsupport@rgcjonas.gmail.com"
				"blur-my-shell@aunetx"
				"dock-from-dash@fthx"
			];
		};
	};

	# Incredibly dumb workaround for the GNOME environment so I can see my newly installed packages when I build my Home Manager. This has been an issue since 2016: https://github.com/NixOS/nixpkgs/issues/12757
	home.activation.copyDesktopFiles = lib.hm.dag.entryAfter ["installPackages"] ''
		if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
			if [ -d "${config.home.homeDirectory}/.nix-profile/share/applications" ]; then
				rm -rf ${config.home.homeDirectory}/.local/share/applications
				mkdir -p ${config.home.homeDirectory}/.local/share/applications
				for file in ${config.home.homeDirectory}/.nix-profile/share/applications/*; do
					ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
				done
      			fi
    		fi
  	'';
	
	# This is mainly for applications that do not come with their own desktop files
	xdg.desktopEntries = {
		# Cider. This is the paid version that uses an AppImage to run. So we must manually create a desktop entry for it
		cider = {
			name = "Cider";
			exec = "appimage-run ${config.home.homeDirectory}/Apps/Cider.AppImage ${settings.WAYLAND_CHROMIUM_FLAGS}";
			terminal = false;
			categories = [ "AudioVideo" "Audio" "Player" ];
			icon = "${config.home.homeDirectory}/Apps/icons/cider.png";
		};
	};
}
