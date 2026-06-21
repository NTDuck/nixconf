{den, ...}: {
  den.aspects.hyprland = {
    nixos = {pkgs, ...}: {
      programs.hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;
      };
    };
  };
}
