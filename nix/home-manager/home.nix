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
	home.stateVersion = "24.11";
	
	# Packages
	nixpkgs.config.allowUnfree = true;
	home.packages = with pkgs; [
		chromium # Secondary browser
		legcord
	 	
	 	# Creative
	 	darktable
	 	# davinci-resolve # Commenting out as davinci-resolve currently has problems on Wayland and it doesn't recognize new NVIDIA drivers atm
	 	gimp
		inkscape
	 	obs-studio
	 	
	 	# CLI Utilities
	 	ffmpeg
	 	git
		win2xcur
	 	yt-dlp
	 	
	 	# Gaming
		gamemode
		prismlauncher
	 	# Steam is handled in the system config.
	 	
	 	# Theming
		font-awesome
	 	posy-cursors
	 	
	 	# Utilities
	 	localsend
	 	mpv
		pwvucontrol
	 	thunderbird
		xorg.xeyes

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
		# WlxOverlay-S: A VR overlay to let you view your desktop on Linux. It is distributed as an AppImage by default.
		# https://github.com/galister/wlx-overlay-s
		wlxoverlay-s = {
			name = "WlxOverlay-S";
			comment = "A custom XSOverlay inspired desktop viewer for VR";
			exec = "appimage-run ${settings.STANDALONE_APPS_DIR}/WlxOverlay-S.AppImage";
			terminal = true;
			categories = [ "Utility" "Accessibility" ];
		};
	};

	# App Configurations
	programs = {
		floorp = {
			enable = true;
			policies = {
				DisableTelemetry = true;
				DisableFirefoxStudies = true;
				DontCheckDefaultBrowser = true;
				SearchBar = "unified";

				Preferences = {
					"browser.topsites.contile.enabled" = "lock-false";
        	"browser.newtabpage.activity-stream.showSponsored" = "lock-false";
        	"browser.newtabpage.activity-stream.system.showSponsored" = "lock-false";
        	"browser.newtabpage.activity-stream.showSponsoredTopSites" = "lock-false";
				};

				ExtensionSettings = {
					# uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
					# Privacy Badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
					# Tree Style Tab
					"treestyletab@piro.sakura.ne.jp" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
						installation_mode = "force_installed";
					};
					# Trace - Online Tracking Protection 
					"{6ff498ff-a3b6-4891-a614-12a825d4efcf}" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/absolutedouble-trace/latest.xpi";
						installation_mode = "force_installed";
					};
					# Bitwarden
					"{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
						installation_mode = "force_installed";
					};
					### YOUTUBE SPECIFIC EXTENSIONS
					# Return YouTube Dislike
					"{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
						installation_mode = "force_installed";
					};
					# SponsorBlock For YouTube
					"sponsorBlocker@ajay.app" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
						installation_mode = "force_installed";
					};
					# Unhook: Remove YouTube Recommended Videos Comments
					"myallychou@gmail.com" = {
						install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
						installation_mode = "force_installed";
					};
				};
			};
		};

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
				jeff-hykin.better-nix-syntax
				ms-vscode.cpptools
				twxs.cmake
			];
		};
	};
}
