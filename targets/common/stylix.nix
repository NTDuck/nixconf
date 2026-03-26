{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;

    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/charcoal-dark.yaml";
    image = ../../assets/wallpapers/girls-last-tour-library.jpg;

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
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
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
      desktop = 0.9;
      terminal = 0.9;
    };
  };
}
