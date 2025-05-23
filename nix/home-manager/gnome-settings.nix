{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
	 	dconf
	 	dconf-editor
	 	gnome-tweaks

	 	gnomeExtensions.appindicator
	 	gnomeExtensions.blur-my-shell
	 	gnomeExtensions.dock-from-dash

		gparted
  ];

  # GNOME Tweaking
	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
			cursor-size = 32;
			cursor-theme = "Posy_Cursor_Black_125_175";
			icon-theme = "Adwaita";
		};
		"org/gnome/mutter" = {
			dynamic-workspaces = true;
			edge-tiling = true;
			experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
		};
		"org/gnome/settings-daemon/plugins/power" = {
			# A workaround for resuming from suspend properly has been found in system-nvidia regarding power management
			# In the case that this issue regresses and comes back, uncomment this.
			# sleep-inactive-ac-type = "nothing";
			sleep-inactive-ac-timeout = 1800;
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