{ config, pkgs, ... }:

let
  color-foreground = config.lib.stylix.colors.withHashtag.base05;
  color-background = config.lib.stylix.colors.withHashtag.base00;
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
          --cmd sway --no-xsession-wrapper \
          --asterisks --asterisks-char '*' \
          --time --time-format '%Y-%m-%d %H:%M:%S' \
          --remember \
          --container-padding 2 \
          --theme "container=${color-background};border=${color-foreground};text=${color-foreground};prompt=${color-foreground};time=${color-foreground};action=${color-foreground};button=${color-foreground};input=${color-foreground}"
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
