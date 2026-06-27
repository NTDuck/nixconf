{den, ...}: {
  den.aspects.dev.agentics.open-interpreter = {
    nixos = {pkgs, ...}: let
      open-interpreter = pkgs.appimageTools.wrapAppImage {
        name = "open-interpreter";
        src = pkgs.fetchurl {
          url = "https://openinterpreter.com/download/linux/appimage";
          hash = "sha256-fJXSmrT/UaEjK+OUaqQt/jGkE/8gKXTi1qv9EOawQGk=";
          name = "Interpreter-latest.AppImage";
        };
      };
    in {
      environment.systemPackages = [open-interpreter];
    };
  };
}
