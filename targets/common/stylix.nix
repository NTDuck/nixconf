{
  config,
  pkgs,
  self,
  inputs,
  ...
}: let
  colors = config.lib.stylix.colors.withHashtag;
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;

    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/charcoal-dark.yaml";
    image =
      pkgs.runCommand "themed-wallpaper.png" {
        nativeBuildInputs = [pkgs.imagemagick];
      } ''
        magick ${self}/assets/wallpapers/oyasumi-punpun.png \
          +level-colors '${colors.base00},${colors.base05}' \
          $out
      '';

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    fonts = {
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.lora;
        name = "Lora";
      };
      monospace = {
        package = pkgs.maple-mono.truetype;
        name = "Maple Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 11;
        terminal = 11;
        desktop = 10;
        popups = 10;
      };
    };

    opacity = {
      applications = 0.8;
      terminal = 0.8;
      desktop = 0.8;
      popups = 0.8;
    };

    targets.console.enable = false;
  };
}
