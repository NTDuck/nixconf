{ den, inputs, ... }: {
  den.aspects.stylix = {
    nixos = {
      pkgs,
      config,
      ...
    }: let
      self = inputs.self;
    posterize = {
      imgPath,
      intensity ? 1,
    }:
      pkgs.unstable.runCommand "posterized.png" {
        nativeBuildInputs = [pkgs.unstable.imagemagick pkgs.unstable.gawk];
      } ''
        PERCENT=$(awk -v i="${toString intensity}" 'BEGIN { print int(i * 100) }')

        if [ "$PERCENT" -eq "0" ]; then
          magick ${imgPath} $out
          exit 0
        fi

        magick ${imgPath} -alpha extract alpha_mask.png

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
          +append palette.png

        magick ${imgPath} -dither FloydSteinberg -remap palette.png remapped.png

        if [ "$PERCENT" -eq "100" ]; then
          magick remapped.png alpha_mask.png -compose CopyOpacity -composite $out
          exit 0
        fi

        magick ${imgPath} remapped.png -define compose:args=$PERCENT -compose blend -composite temp_blended.png
        magick temp_blended.png alpha_mask.png -compose CopyOpacity -composite $out
      '';

    pad = {
      imgPath,
      heightRatio,
      screenWidth ? 1366,
      screenHeight ? 768,
    }: let
      targetHeight = builtins.floor (screenHeight * heightRatio);
    in
      pkgs.unstable.runCommand "padded.png" {
        nativeBuildInputs = [pkgs.unstable.imagemagick];
      } ''
        magick ${imgPath} \
          -resize x${toString targetHeight} \
          -background '${config.lib.stylix.colors.withHashtag.base05}' \
          -gravity center \
          -extent ${toString screenWidth}x${toString screenHeight} \
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

      image = pad {
        imgPath = posterize {
          imgPath = "${self}/assets/wallpapers/shifting-tides.jpg";
          intensity = 0.75;
        };
        heightRatio = 0.80;
      };

      cursor = {
        package = pkgs.unstable.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      fonts = {
        sansSerif = {
          package = pkgs.unstable.inter;
          name = "Inter";
        };
        serif = {
          package = pkgs.unstable.lora;
          name = "Lora";
        };
        monospace = {
          package = pkgs.unstable.maple-mono.truetype;
          name = "Maple Mono";
        };
        emoji = {
          package = pkgs.unstable.noto-fonts-color-emoji;
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
  };
  };
}
