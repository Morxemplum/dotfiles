{ config, pkgs, lib, ... }:

let
	settings = import ./user-settings.nix;
	unstable = import <nixos-unstable> {
		config.allowUnfree = true;
	};
in
{
	# Import settings
	imports = [
		./gnome-settings.nix
		./hyprland-settings.nix
	];

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
	 	
	 	# Theming
	 	posy-cursors
	 	
	 	# Utilities
	 	localsend
	 	mpv
	 	thunderbird

		# VR
		sidequest
	];
	
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
	programs = {
		# TODO: Add Floorp configuration (it's only in home-manager unstable, currently)
		kitty = lib.mkForce {
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

		vscode = {
			enable = true;
			package = pkgs.vscodium;
			extensions = with pkgs.vscode-extensions; [
				jnoortheen.nix-ide
			];
		};
	};
}
