{den, ...}: {
  den.aspects.hyprland = {
    nixos = {pkgs, ...}: {
      programs.hyprland.enable = true;
      programs.hyprland.package = pkgs.unstable.hyprland;
    };
  };
}
