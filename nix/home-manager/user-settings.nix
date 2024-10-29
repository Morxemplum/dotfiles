rec {
	USER_NAME = "morxemplum";
	HOME_DIR = "/home/${USER_NAME}";

	# Got any AppImages? Any standalone binary? Put them all in a directory for easy referencing
	STANDALONE_APPS_DIR = "${HOME_DIR}/Apps";
	STANDALONE_APPS_ICONS = "${STANDALONE_APPS_DIR}/icons";
	
	# Useful constants
	WAYLAND_CHROMIUM_FLAGS = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
}
