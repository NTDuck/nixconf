{ config, pkgs, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
          --time --remember \
          --container-padding 2 --no-xsession-wrapper --cmd sway \
          --theme "container=${colors.base00};border=${colors.base0D};text=${colors.base05};prompt=${colors.base0E};time=${colors.base0C};action=${colors.base0B};button=${colors.base0A};input=${colors.base05}'
        ''; # References `sway` therefore not clean
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
  console.earlySetup = true;
}
