{den, ...}: {
  den.aspects.compositors.hyprland = {
    nixos = {pkgs, ...}: {
      programs.hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;
      };
    };
  };
}
