{den, ...}: {
  den.aspects.dev.agentics.open-interpreter = {
    nixos = {pkgs, ...}: let
      open-interpreter = pkgs.appimageTools.wrapAppImage {
        name = "open-interpreter";
        src = pkgs.fetchurl {
          url = "https://openinterpreter.com/download/linux/appimage";
          hash = "";
          name = "Interpreter-latest.AppImage";
        };
        # extraPkgs = pkgs: with pkgs; [];
      };
    in {
      environment.systemPackages = [open-interpreter];
    };
  };
}
