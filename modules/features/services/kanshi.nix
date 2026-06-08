{
  flake.modules.homeManager.kanshi = {
    pkgs,
    ...
  }: {
    services.kanshi = {
      enable = true;
      systemdTarget = "sway-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
            }
          ];
        }
        {
          profile.name = "projector";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
            }
            {
              criteria = "HDMI-A-1";
              status = "enable";
              position = "0,0";
              mode = "1366x768";
            }
          ];
        }
      ];
    };

    home.packages = [
      pkgs.unstable.wlr-randr
      pkgs.unstable.wdisplays
    ];
  };
}
