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
		audacity
	 	darktable
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
		xorg.xcursorgen

		# VR
		sidequest
	];
	
	# This is mainly for applications that do not come with their own desktop files or do not respect NIXOS_OZONE_WL
	xdg.desktopEntries = {
		# Bopimo. A Super Mario 64 like game, but without Nintendo IP.
		bopimo = {
			name = "Bopimo! Client";
			comment = "Play Bopimo! multiplayer or singleplayer";
			exec = "steam-run ${settings.HOME_DIR}/.local/share/Bopimo!/Client/bopimo_client.x86_64";
			categories = [ "Game" ];
			icon = "bopimo";
		};
		bopimo-launcher = {
			name = "Bopimo! Launcher";
			comment = "Bopimo’s official game launcher and updater.";
			exec = "appimage-run ${settings.HOME_DIR}/.local/share/Bopimo!/Launcher/bopimo-launcher.AppImage --no-sandbox %U";
			terminal = false;
			categories = [ "Game" ];
			icon = "bopimo";
			mimeType = [ "x-scheme-handler/bopimo" ];

			actions = {
				"Uninstall" = {
					name = "Uninstall";
					exec = "appimage-run ${settings.HOME_DIR}/.local/share/Bopimo!/Launcher/bopimo-launcher.AppImage --no-sandbox --uninstall-prompt";
				};
			};
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

	# When setting the browser configurations, there are a few files that will conflict and needed to be backed up.
	# However, home-manager refuses to delete backups, and this turns out to be on purpose. An issue has been raised about this.
	# https://github.com/nix-community/home-manager/issues/4199
	# https://github.com/nix-community/home-manager/pull/4971
	home.activation.removeBrowserBackups = lib.hm.dag.entryAfter ["checkLinkTargets"] ''
		if [ -d "${settings.HOME_DIR}/.floorp/default" ]; then
			rm -f ${settings.HOME_DIR}/.floorp/default/search.json.mozlz4.backup
		fi
	'';

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
					"browser.topsites.contile.enabled" = { Value = false; Status = "locked"; };
					"browser.newtabpage.activity-stream.showSponsored" = { Value = false; Status = "locked"; };
					"browser.newtabpage.activity-stream.system.showSponsored" = { Value = false; Status = "locked"; };
					"browser.newtabpage.activity-stream.showSponsoredTopSites" = { Value = false; Status = "locked"; };
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
			profiles = {
				# Default Profile, set to your username
				default = {
					id = 0;
					name = "${settings.USER_NAME}";
					search = {
						default = "Startpage";
						engines = {
							"Amazon.com".metaData.hidden = true;
							"Bing".metaData.hidden = true;
							"eBay".metaData.hidden = true;
							"Ecosia" = {
								urls = [{
									template = "https://www.ecosia.org/search";
									params = [
										{ name = "method"; value = "index"; }
										{ name = "q"; value = "{searchTerms}"; }
									];
								}];
								definedAliases = [ "@ec" ];
							};
							"Nix Packages" = {
								urls = [{
									template = "https://search.nixos.org/packages";
									params = [
										{ name = "type"; value = "packages"; }
										{ name = "query"; value = "{searchTerms}"; }
									];
								}];
								icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
								definedAliases = [ "@np" ];
							};
							"Wikipedia (en)".metadata.alias = "@wiki";
							"You.com".metaData.hidden = true;
						};
					};
					# While you can output the whole CSS in here, I find it better to just pull it in from a file
					userChrome = builtins.readFile "${settings.CONFIG_DIR}/floorp/userChrome.css";

					# Although Floorp does incorporate Betterfox, the maintainer recommends you reapply it.
					# https://github.com/yokoffing/Betterfox/blob/esr128/user.js
					extraConfig = builtins.readFile "${settings.CONFIG_DIR}/floorp/user.js";
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
