{
  den,
  inputs,
  ...
}: {
  den.aspects.stylix = {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      stylix = let
        polarity = "dark";
      in {
        enable = true;
        inherit polarity;

        base16Scheme = let
          themes = {
            light = "${pkgs.base16-schemes}/share/themes/ia-light.yaml";
            dark = "${pkgs.base16-schemes}/share/themes/ia-dark.yaml";
          };
        in
          themes.${polarity};

        image = "${inputs.self}/assets/wallpapers/girls-last-tour-library.jpg";

        cursor = {
          package = pkgs.unstable.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24; # 16
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
            # applications = 11;
            # terminal = 11;
            # desktop = 10;
            # popups = 10;

            applications = 16;
            terminal = 16;
            desktop = 16;
            popups = 16;
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
