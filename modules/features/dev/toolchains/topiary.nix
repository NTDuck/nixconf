{den, ...}: {
  den.aspects.dev.toolchains.topiary = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        # nixpkgs-unstable cargo-setup-hook exports AWS_LC_SYS_USE_SYSTEM=1,
        # but the aws-lc-sys crate override doesn't reach vendored deps
        # ("requires a system-installed AWS-LC" build failure).
        # pinned to nixpkgs-unstable rev f4a03c008967841f2a0b3cb7c436fc6fc31671f6
        (pkgs.unstable.topiary.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
          buildInputs = (old.buildInputs or []) ++ [ pkgs.unstable.aws-lc ];
        }))

        # onig_sys 69.9.1: RUSTONIG_SYSTEM_LIBONIG=1 (cargo-setup-hook)
        # needs system oniguruma via pkg-config — crate override absent.
        (pkgs.unstable.nickel.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
          buildInputs = (old.buildInputs or []) ++ [ pkgs.unstable.oniguruma ];
        }))
        pkgs.unstable.ts_query_ls # .scm
      ];
    };
  };
}
