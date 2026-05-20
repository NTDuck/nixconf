{
  config,
  pkgs,
  self,
  inputs,
  ...
}: let
  posterize = {
    imgPath,
    intensity ? 1,
  }:
    pkgs.runCommand "posterized.png" {
      nativeBuildInputs = [pkgs.imagemagick pkgs.gawk];
    } ''
      PERCENT=$(awk -v i="${toString intensity}" 'BEGIN { print int(i * 100) }')

      if [ "$PERCENT" -eq "0" ]; then
        magick ${imgPath} $out
        exit 0
      fi

      magick ${imgPath} -alpha extract alpha_mask.png

      magick 
        xc:'${config.lib.stylix.colors.withHashtag.base00}' 
        xc:'${config.lib.stylix.colors.withHashtag.base01}' 
        xc:'${config.lib.stylix.colors.withHashtag.base02}' 
        xc:'${config.lib.stylix.colors.withHashtag.base03}' 
        xc:'${config.lib.stylix.colors.withHashtag.base04}' 
        xc:'${config.lib.stylix.colors.withHashtag.base05}' 
        xc:'${config.lib.stylix.colors.withHashtag.base06}' 
        xc:'${config.lib.stylix.colors.withHashtag.base07}' 
        xc:'${config.lib.stylix.colors.withHashtag.base08}' 
        xc:'${config.lib.stylix.colors.withHashtag.base09}' 
        xc:'${config.lib.stylix.colors.withHashtag.base0A}' 
        xc:'${config.lib.stylix.colors.withHashtag.base0B}' 
        xc:'${config.lib.stylix.colors.withHashtag.base0C}' 
        xc:'${config.lib.stylix.colors.withHashtag.base0D}' 
        xc:'${config.lib.stylix.colors.withHashtag.base0E}' 
        xc:'${config.lib.stylix.colors.withHashtag.base0F}' 
        +append palette.png

      magick ${imgPath} -dither FloydSteinberg -remap palette.png remapped.png

      if [ "$PERCENT" -eq "100" ]; then
        magick remapped.png alpha_mask.png -compose CopyOpacity -composite $out
        exit 0
      fi

      magick ${imgPath} remapped.png -define compose:args=$PERCENT -compose blend -composite temp_blended.png
      magick temp_blended.png alpha_mask.png -compose CopyOpacity -composite $out
    '';

  # Hard-coded so is bad!
  pad = {
    imgPath,
    heightRatio,
    screenWidth ? 1366,
    screenHeight ? 768,
  }: let
    targetHeight = builtins.floor (screenHeight * heightRatio);
  in
    pkgs.runCommand "padded.png" {
      nativeBuildInputs = [pkgs.imagemagick];
    } ''
      magick ${imgPath} 
        -resize x${toString targetHeight} 
        -background '${config.lib.stylix.colors.withHashtag.base05}' 
        -gravity center 
        -extent ${toString screenWidth}x${toString screenHeight} 
        $out
    '';
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;

    polarity = "dark";
    base16Scheme = {
      scheme = "catppuccin-latte";
      name = "Catppuccin-Latte";
      author = "Catppuccin";
      base00 = "eff1f5"; # Base
      base01 = "e6e9ef"; # Mantle
      base02 = "dce0e8"; # Crust
      base03 = "bcc0cc"; # Surface1
      base04 = "acb0be"; # Surface2
      base05 = "9ca0b0"; # Overlay0
      base06 = "8c8fa1"; # Overlay1
      base07 = "7c7f93"; # Overlay2
      base08 = "d20f39"; # Red
      base09 = "fe640b"; # Peach
      base0A = "df8e1d"; # Yellow
      base0B = "40a02b"; # Green
      base0C = "179287"; # Teal
      base0D = "1e66f5"; # Blue
      base0E = "8839ef"; # Mauve
      base0F = "ea76cb"; # Pink
    };

    image = pad {
      imgPath = posterize {
        imgPath = "${self}/assets/wallpapers/shifting-tides.jpg";
        intensity = 0.75;
      };
      heightRatio = 0.80;
    };

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
