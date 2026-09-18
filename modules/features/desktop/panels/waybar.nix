{den, ...}: {
  den.aspects.desktop.panels.waybar = {
    homeManager = {pkgs, ...}: {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        package = pkgs.unstable.waybar;
      };
    };
  };
}
