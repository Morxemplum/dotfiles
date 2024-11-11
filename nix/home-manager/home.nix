{ config, pkgs, lib, ... }:

let
	settings = import ./user-settings.nix;
	unstable = import <nixos-unstable> {
		config.allowUnfree = true;
	};
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
		chromium # Secondary browser
		legcord
	 	
	 	# Creative
	 	darktable
	 	# davinci-resolve # Commenting out as davinci-resolve currently has problems on Wayland and it doesn't recognize new NVIDIA drivers atm
	 	gimp
	 	obs-studio
	 	
	 	# CLI Utilities
	 	ffmpeg
	 	git
	 	yt-dlp
	 	
	 	# Gaming
		gamemode
		prismlauncher
	 	# Steam is handled in the system config.
	 	
	 	# GNOME Stuff
	 	dconf
	 	gnome.dconf-editor
	 	gnome.gnome-tweaks
	 	gnomeExtensions.appindicator
	 	gnomeExtensions.blur-my-shell
	 	gnomeExtensions.dock-from-dash
	 	
	 	# Theming
	 	posy-cursors
	 	
	 	# Utilities
	 	localsend
	 	mpv
	 	thunderbird
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
			# TODO: Add "xwayland-native-scaling" when updated to GNOME 47
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
	
	# This is mainly for applications that do not come with their own desktop files or do not respect NIXOS_OZONE_WL
	xdg.desktopEntries = {
		# Cider. This is the paid version that uses an AppImage to run. So we must manually create a desktop entry for it
		cider = {
			name = "Cider";
			exec = "appimage-run ${settings.STANDALONE_APPS_DIR}/Cider.AppImage";
			terminal = false;
			categories = [ "AudioVideo" "Audio" "Player" "Network" "Music" ];
			icon = "${settings.STANDALONE_APPS_ICONS}/cider.png";
		};
		# Discord
		legcord = {
			name = "Legcord";
			exec = "${pkgs.legcord}/bin/legcord ${settings.WAYLAND_CHROMIUM_FLAGS}";
			terminal = false;
			categories = [ "Network" "InstantMessaging" "Chat" ];
			icon = "legcord";
		};
		# Minecraft: Bedrock Edition (mcpelauncher). It also uses AppImage (due to some of the maintainer's practices, it's REALLY hard to build a proper Nixpkg for)
		# https://github.com/minecraft-linux/mcpelauncher-manifest
		mcpelauncher-ui = {
			name = "Minecraft: Bedrock Edition";
			comment = "Play Minecraft Bedrock Edition through Android runtime";
			exec = "appimage-run ${settings.STANDALONE_APPS_DIR}/Minecraft_Bedrock_Launcher.AppImage";
			terminal = false;
			categories = [ "Game" ];
			icon = "${settings.STANDALONE_APPS_ICONS}/MC_BE.png";
		};
	};

	# App Configurations
	programs.kitty = lib.mkForce {
		enable = true;
		settings = {
    			background_opacity = "0.8";
			confirm_os_window_close = 0;
			dynamic_background_opacity = true;
			tab_bar_edge = "top";
			wayland_titlebar_color = "system";
			window_padding_width = 10;
		};
	};
	
	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		extensions = with pkgs.vscode-extensions; [
			jnoortheen.nix-ide
		];
	};	
}
