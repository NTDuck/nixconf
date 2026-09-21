{
  den,
  inputs,
  ...
}: {
  den.aspects.desktop.theming.stylix = {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      stylix = {
        enable = true;

        polarity = "dark";

        base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa-dragon.yaml";
        image = "${inputs.self}/assets/wallpapers/230826-2.png";

        cursor = {
          package = pkgs.unstable.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
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
          # NF-CN variant (2026-09-21): the plain truetype build carries NO
          # Nerd-Font glyphs, so any NF glyph (waybar/yambar modules, shell
          # prompts) rendered as tofu when this family was resolved. Commit
          # 3123d86 claimed a stylix font pin for the waybar fix but only the
          # comment landed — this block is the actual fix.
          monospace = {
            package = pkgs.unstable.maple-mono.NF-CN;
            name = "Maple Mono NF CN";
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
          applications = 0.85;
          terminal = 0.75;
          desktop = 0.85;
          popups = 0.8;
        };
      };
    };
  };
}
