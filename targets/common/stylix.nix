{
  config,
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
    base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-dune.yaml";

    image = ../../assets/wallpapers/funeral-of-the-dead-butterflies.png;

    polarity = "dark";

    fonts = {
      sansSerif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Sans";
      };
      serif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Serif";
      };
      monospace = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Mono";
      };
      emoji = {
        package = pkgs.twitter-color-emoji;
        name = "Twitter Color Emoji";
      };

      sizes.terminal = 11;
    };
  };
}
