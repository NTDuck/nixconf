{den, ...}: {
  den.aspects.dev.toolchains.go = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.golangci-lint
        pkgs.unstable.golangci-lint-langserver
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.go = {
        enable = true;
        package = pkgs.unstable.go;
      };
    };
  };
}
