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

        base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-dark.yaml";
        override = {
          base08 = "e06c75";
        };

        image = "${inputs.self}/assets/wallpapers/rockman.png";

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
          terminal = 0.75;
          desktop = 0.8;
          popups = 0.8;
        };
      };

      fonts.packages = [
        pkgs.unstable.nerd-fonts._0xproto
        pkgs.unstable.nerd-fonts._3270
        pkgs.unstable.nerd-fonts.adwaita-mono
        pkgs.unstable.nerd-fonts.agave
        pkgs.unstable.nerd-fonts.anonymice
        pkgs.unstable.nerd-fonts.arimo
        pkgs.unstable.nerd-fonts.atkynson-mono
        pkgs.unstable.nerd-fonts.aurulent-sans-mono
        pkgs.unstable.nerd-fonts.bigblue-terminal
        pkgs.unstable.nerd-fonts.bitstream-vera-sans-mono
        pkgs.unstable.nerd-fonts.blex-mono
        pkgs.unstable.nerd-fonts.caskaydia-cove
        pkgs.unstable.nerd-fonts.caskaydia-mono
        pkgs.unstable.nerd-fonts.code-new-roman
        pkgs.unstable.nerd-fonts.comic-shanns-mono
        pkgs.unstable.nerd-fonts.commit-mono
        pkgs.unstable.nerd-fonts.cousine
        pkgs.unstable.nerd-fonts.d2coding
        pkgs.unstable.nerd-fonts.daddy-time-mono
        pkgs.unstable.nerd-fonts.dejavu-sans-mono
        pkgs.unstable.nerd-fonts.departure-mono
        pkgs.unstable.nerd-fonts.droid-sans-mono
        pkgs.unstable.nerd-fonts.envy-code-r
        pkgs.unstable.nerd-fonts.fantasque-sans-mono
        pkgs.unstable.nerd-fonts.fira-code
        pkgs.unstable.nerd-fonts.fira-mono
        pkgs.unstable.nerd-fonts.geist-mono
        pkgs.unstable.nerd-fonts.go-mono
        pkgs.unstable.nerd-fonts.gohufont
        pkgs.unstable.nerd-fonts.hack
        pkgs.unstable.nerd-fonts.hasklug
        pkgs.unstable.nerd-fonts.heavy-data
        pkgs.unstable.nerd-fonts.hurmit
        pkgs.unstable.nerd-fonts.im-writing
        pkgs.unstable.nerd-fonts.inconsolata
        pkgs.unstable.nerd-fonts.inconsolata-go
        pkgs.unstable.nerd-fonts.inconsolata-lgc
        pkgs.unstable.nerd-fonts.intone-mono
        pkgs.unstable.nerd-fonts.iosevka
        pkgs.unstable.nerd-fonts.iosevka-term
        pkgs.unstable.nerd-fonts.iosevka-term-slab
        pkgs.unstable.nerd-fonts.jetbrains-mono
        pkgs.unstable.nerd-fonts.lekton
        pkgs.unstable.nerd-fonts.liberation
        pkgs.unstable.nerd-fonts.lilex
        # pkgs.unstable.nerd-fonts.m+
        pkgs.unstable.nerd-fonts.martian-mono
        pkgs.unstable.nerd-fonts.meslo-lg
        pkgs.unstable.nerd-fonts.monaspace
        pkgs.unstable.nerd-fonts.monofur
        pkgs.unstable.nerd-fonts.monoid
        pkgs.unstable.nerd-fonts.mononoki
        pkgs.unstable.nerd-fonts.noto
        pkgs.unstable.nerd-fonts.open-dyslexic
        pkgs.unstable.nerd-fonts.overpass
        pkgs.unstable.nerd-fonts.profont
        pkgs.unstable.nerd-fonts.proggy-clean-tt
        pkgs.unstable.nerd-fonts.recursive-mono
        pkgs.unstable.nerd-fonts.roboto-mono
        pkgs.unstable.nerd-fonts.sauce-code-pro
        pkgs.unstable.nerd-fonts.shure-tech-mono
        pkgs.unstable.nerd-fonts.space-mono
        pkgs.unstable.nerd-fonts.symbols-only
        pkgs.unstable.nerd-fonts.terminess-ttf
        pkgs.unstable.nerd-fonts.tinos
        pkgs.unstable.nerd-fonts.ubuntu
        pkgs.unstable.nerd-fonts.ubuntu-mono
        pkgs.unstable.nerd-fonts.ubuntu-sans
        pkgs.unstable.nerd-fonts.victor-mono
        pkgs.unstable.nerd-fonts.zed-mono
      ];
    };
  };
}
