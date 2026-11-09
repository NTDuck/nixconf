# omp release binary (2026-11-09): upstream can1357/oh-my-pi ships a
# glibc-linked ELF per GitHub release (only libc/libm/libpthread/libdl —
# verified with ldd), so fetchurl + autoPatchelfHook replaces the ~10min
# bun2nix + cargo source build on every llm-agents bump. Decided against
# the musl variant: it hardcodes /lib/ld-musl-x86-64.so.1 and drags in
# musl+libstdc++, which NixOS glibc hosts can't satisfy cleanly.
# autoPatchelfHook rewrites the interpreter to the store glibc, so the
# hash-pinned upstream artifact is byte-identical to the release.
#
# Consumers: harnesses/oh-my-pi.nix (shared aspect + dell aliases) and
# the legion-private oh-my-pi.nix (omp/ompl/omprp wrappers). Single
# source of truth for the version+hash pin: bump BOTH fields together,
# then smoke-test `omp --version`.
{
  lib,
  pkgs,
}: let
  # Pinned to release v18.18.3 (2026-11-09, current latest at cutover).
  # sha256 from upstream SHA256SUMS.txt (omp-linux-x64), re-verified
  # locally.
  ompRelease = {
    version = "18.18.3";
    # Upstream SHA256SUMS is raw-binary sha256; this is the same digest in
    # nix base64 form (verified: matches sha256sum of the fetched artifact
    # 8c9a178fed74ec1da21aafb7d28cd9839b3b0c9e7d607c86cc3b6177355729f4).
    hash = "sha256-jJoXj+107B2iGq+30ozZg5s7DJ59YHyGzDthdzVXKfQ=";
  };

  omp-bin = {
    pkgs,
    lib,
  }: {version, hash}:
    pkgs.stdenv.mkDerivation {
      pname = "omp";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
        inherit hash;
      };

      dontUnpack = true;
      dontBuild = true;

      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib];

      installPhase = ''
        runHook preInstall
        install -Dm755 $src $out/bin/omp
        runHook postInstall
      '';

      meta = {
        description = "Oh-My-Pi (omp) agent harness, upstream release binary";
        homepage = "https://github.com/can1357/oh-my-pi";
        license = lib.licenses.mit;
        mainProgram = "omp";
        platforms = ["x86_64-linux"];
      };
    };
in {
  inherit ompRelease;
  omp = omp-bin {inherit pkgs lib;} ompRelease;
}
