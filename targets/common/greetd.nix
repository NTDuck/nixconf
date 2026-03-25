{ config, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember  --asterisks  --container-padding 2 --no-xsession-wrapper --cmd sway --theme 'border=${config.lib.stylix.colors.base0D};text=${config.lib.stylix.colors.base05};prompt=${config.lib.stylix.colors.base0A};time=${config.lib.stylix.colors.base08};action=${config.lib.stylix.colors.base0D};button=${config.lib.stylix.colors.base09};container=${config.lib.stylix.colors.base00};input=${config.lib.stylix.colors.base05}'"; # References `sway` therefore not clean
        user = "greeter";
      };
    };
  };

  # https://github.com/dwilliam62/niri-nixos/blob/243114c976cfa30eaf69f0a0df19ee84f69fe201/system/greeter/greetd.nix
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  # systemd = {
  #   # To prevent getting stuck at shutdown
  #   extraConfig = "DefaultTimeoutStopSec=10s";
  #   services.greetd.serviceConfig = {
  #     Type = "idle";
  #     StandardInput = "tty";
  #     StandardOutput = "tty";
  #     StandardError = "journal";
  #     TTYReset = true;
  #     TTYVHangup = true;
  #     TTYVTDisallocate = true;
  #   };
  # };

  services.xserver.enable = false;
}
