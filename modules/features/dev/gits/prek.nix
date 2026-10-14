{den, ...}: {
  # prek: fast Git pre-commit hook runner re-engineered in Rust (drop-in pre-commit alternative).
  den.aspects.dev.gits.prek = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.prek
      ];
    };
  };
}
