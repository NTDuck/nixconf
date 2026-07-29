{den, ...}: {
  den.aspects.office.libreoffice = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.libreoffice-qt6
      ];
    };

    homeManager = {
      xdg.mimeApps.defaultApplications = {
        "application/msword" = ["libreoffice-writer.desktop"];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["libreoffice-writer.desktop"];
        "application/vnd.ms-excel" = ["libreoffice-calc.desktop"];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = ["libreoffice-calc.desktop"];
        "application/vnd.ms-powerpoint" = ["libreoffice-impress.desktop"];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["libreoffice-impress.desktop"];
        "application/vnd.oasis.opendocument.text" = ["libreoffice-writer.desktop"];
        "application/vnd.oasis.opendocument.spreadsheet" = ["libreoffice-calc.desktop"];
        "application/vnd.oasis.opendocument.presentation" = ["libreoffice-impress.desktop"];
      };
    };
  };

  den.aspects.office.zathura = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      programs.zathura = {
        enable = true;
        package = pkgs.unstable.zathura;

        options = {
          adjust-open = "width"; # "best-fit"
          double-click-follow = "false";
          font = "${config.stylix.fonts.monospace.name} normal ${toString config.stylix.fonts.sizes.applications}";
          guioptions = "chv";
          page-v-padding = "2";
          page-h-padding = "2";
          pages-per-row = "1";
          scroll-step = "100";
          scroll-page-aware = "true";
          scroll-full-overlap = "0.01";
          selection-clipboard = "clipboard";
          zoom-min = "10";
        };

        mappings = {
          "[fullscreen] a" = "adjust_window best-fit";
          "[fullscreen] s" = "adjust_window width";
          "<C-i>" = "zoom in";
          "<C-o>" = "zoom out";
        };
      };
    };
  };
}
