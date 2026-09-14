{den, ...}: {
  den.aspects.apps.office.libreoffice = {
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
}
