# omp release binary (2026-11-09): upstream can1357/oh-my-pi ships a
# glibc-linked bun single-file executable per GitHub release
# (omp-linux-x64, only libc/libm/libpthread/libdl per ldd), so fetchurl
# replaces the ~10min bun2nix + cargo source build on every llm-agents
# bump. Decided against the musl variant: it hardcodes
# /lib/ld-musl-x86-64.so.1 and drags in musl+libstdc++, which NixOS
# glibc hosts can't satisfy cleanly.
#
# CRITICAL (2026-11-09 breakage, fixed): this is a BUN STANDALONE — the
# JS bundle is embedded in the ELF with a self-locating trailer
# ("--- Bun! ---"). autoPatchelfHook broke it (printed the bun CLI
# instead of omp): beyond the interpreter swap it also added the loader
# as a DT_NEEDED entry and shuffled ELF metadata, which detaches bun's
# embedded-entry detection. The minimal safe patch is patchelf
# --set-interpreter to the nix glibc loader ONLY — no autoPatchelfHook,
# no rpath, no strip (nix glibc's ld.so resolves its own libc/libm/
# libpthread/libdl via baked-in search; verified with `env -i`).
#
# Consumers: harnesses/oh-my-pi.nix (shared aspect + dell aliases) and
# the legion-private oh-my-pi.nix (omp/ompl/omprp wrappers). Single
# source of truth for the version+hash pin: bump BOTH fields together,
# then smoke-test `omp --version` (must print omp/..., never bun).
{
  lib,
  pkgs,
}: let
  # Pinned to release v18.18.3 (2026-11-09, current latest at cutover).
  # Upstream SHA256SUMS.txt is raw-hex; hash below is the same digest in
  # nix base64 (hex 8c9a178fed74ec1da21aafb7d28cd9839b3b0c9e7d607c86cc3b
  # 6177355729f4).
  ompRelease = {
    version = "18.18.3";
    hash = "sha256-jJoXj+107B2iGq+30ozZg5s7DJ59YHyGzDthdzVXKfQ=";
  };

  omp-bin = {
    pkgs,
    lib,
  }: {
    version,
    hash,
  }:
    pkgs.stdenv.mkDerivation {
      pname = "omp";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
        inherit hash;
      };

      dontUnpack = true;
      dontBuild = true;
      # Bun single-file executables break under strip/autoPatchelf (see
      # header comment): interpreter-only patchelf is the entire
      # safe-patch surface.
      dontStrip = true;
      dontPatchELF = true;

      nativeBuildInputs = [pkgs.patchelf];

      installPhase = ''
        runHook preInstall
        install -Dm755 $src $out/bin/omp
        # Interpreter-only rewrite: nix glibc ld.so resolves the needed
        # libc/libm/libpthread/libdl itself.
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/omp
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
