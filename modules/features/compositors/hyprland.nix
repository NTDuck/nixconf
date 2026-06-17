{den, ...}: {
  den.aspects.Hyprland = {
    nixos = {pkgs, ...}: {
      programs.hyprland.enable = true;
      programs.hyprland.package = pkgs.unstable.hyprland;
    };
  };
}
