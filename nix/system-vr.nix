{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    avahi
    # TODO: If we get a Nvidia driver 565.77.01 or later, remove this package
    monado-vulkan-layers
  ];
  hardware.graphics.extraPackages = with pkgs; [
    monado-vulkan-layers
  ];

  services.wivrn = {
    enable = true;
    openFirewall = true;

    defaultRuntime = true;

    monadoEnvironment = {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "0"; # Even though Quest 2 supports hand tracking, not my biggest priority
    };

    # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
    config = {
      enable = true;
      json = {
        # 1.0x foveation scaling
        scale = 1.0;
        # 50 Mb/s
        bitrate = 50000000;
        encoders = [
          {
            encoder = "nvenc";
            codec = "h264";
            # 1.0 x 1.0 scaling
            width = 1.0;
            height = 1.0;
            offset_x = 0.0;
            offset_y = 0.0;
          }
        ];
      };
    };
  };
}