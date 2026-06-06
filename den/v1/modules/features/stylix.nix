{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.stylix = {

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

  };
}
