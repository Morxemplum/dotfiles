{ config, pkgs, lib, ... }:

{
  home.pkgs = with pkgs; [
	 	dconf
	 	gnome.dconf-editor
	 	gnome.gnome-tweaks
	 	gnomeExtensions.appindicator
	 	gnomeExtensions.blur-my-shell
	 	gnomeExtensions.dock-from-dash
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

  # Incredibly dumb workaround for the GNOME environment so I can see my newly installed packages when I build my Home Manager. 
  # This has been an issue since 2016: https://github.com/NixOS/nixpkgs/issues/12757
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
}