{
  flake.modules.nixos.greetd = {
    config,
    pkgs,
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
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
            --theme "container=${colors.base00};border=${colors.base05};text=${colors.base05};prompt=${colors.base05};time=${colors.base05};action=${colors.base05};button=${colors.base05};input=${colors.base05}"
          '';
          user = "greeter";
        };
      };
    };

    services.xserver.enable = false;
    console.earlySetup = true;
  };
}
