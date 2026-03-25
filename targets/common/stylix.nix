{ pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-dune.yaml";
    
    image = ../../assets/wallpapers/lobotomy-ego-solemn-lament-yi-sang.jpg;
    
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.intel-one-mono;
        name = "Intel One Mono";
      };

      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      emoji = config.stylix.fonts.monospace;
      
      sizes.terminal = 11;
    };
  };
}
