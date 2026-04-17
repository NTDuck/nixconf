{
  config,
  pkgs,
  self,
  inputs,
  ...
}: let
  posterize = imgPath:
    pkgs.runCommand "posterized.png" {
      nativeBuildInputs = [pkgs.imagemagick];
    } ''
      magick \
        xc:'${config.lib.stylix.colors.withHashtag.base00}' \
        xc:'${config.lib.stylix.colors.withHashtag.base01}' \
        xc:'${config.lib.stylix.colors.withHashtag.base02}' \
        xc:'${config.lib.stylix.colors.withHashtag.base03}' \
        xc:'${config.lib.stylix.colors.withHashtag.base04}' \
        xc:'${config.lib.stylix.colors.withHashtag.base05}' \
        xc:'${config.lib.stylix.colors.withHashtag.base06}' \
        xc:'${config.lib.stylix.colors.withHashtag.base07}' \
        xc:'${config.lib.stylix.colors.withHashtag.base08}' \
        xc:'${config.lib.stylix.colors.withHashtag.base09}' \
        xc:'${config.lib.stylix.colors.withHashtag.base0A}' \
        xc:'${config.lib.stylix.colors.withHashtag.base0B}' \
        xc:'${config.lib.stylix.colors.withHashtag.base0C}' \
        xc:'${config.lib.stylix.colors.withHashtag.base0D}' \
        xc:'${config.lib.stylix.colors.withHashtag.base0E}' \
        xc:'${config.lib.stylix.colors.withHashtag.base0F}' \
        +append palette.png # lossless

      magick ${imgPath} \
        -dither FloydSteinberg \
        -remap palette.png \
        $out
    '';
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;

    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/charcoal-dark.yaml";
    image = posterize "${self}/assets/wallpapers/omori-persist.jpg";

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
