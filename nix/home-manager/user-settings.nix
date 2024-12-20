rec {
	USER_NAME = "morxemplum";
	HOME_DIR = "/home/${USER_NAME}";

	# References to other folder locations in dotfiles
	DOTFILES_ROOT = "${HOME_DIR}/dotfiles";
	CONFIG_DIR = "${DOTFILES_ROOT}/config";

	# Got any AppImages? Any standalone binary? Put them all in a directory for easy referencing
	STANDALONE_APPS_DIR = "${HOME_DIR}/Apps";
	STANDALONE_APPS_ICONS = "${STANDALONE_APPS_DIR}/icons";
	
	# Useful constants
	WAYLAND_CHROMIUM_FLAGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
}
