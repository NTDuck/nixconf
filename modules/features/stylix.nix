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

      stylix = {
        enable = true;

        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/charcoal-dark.yaml";

        image = "${inputs.self}/assets/wallpapers/limbus-company.jpg";

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
