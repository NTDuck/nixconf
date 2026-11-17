# omp release binary: upstream can1357/oh-my-pi ships a
# glibc-linked bun single-file executable per GitHub release
# (omp-linux-x64, only libc/libm/libpthread/libdl per ldd).
#
# PIN (_pin.json): version and hash are pinned in _pin.json (updated via
# _update.sh or passthru.updateScript) instead of mutable flake inputs.
# Note: Declaring mutable URLs (releases.atom / SHA256SUMS.txt) as flake
# inputs breaks hermetic evaluation and triggers NAR hash mismatch on
# nh os switch whenever upstream publishes a new release.
#
# HISTORY:
# - 2026-11-09: hand-pinned literals replaced source build
# - 2026-11-14: attempted flake inputs for auto-update; proved broken
#   because mutable URLs violate flake lock narHash once content changes
# - 2026-11-17: decoupled from flake inputs to _pin.json + _update.sh
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
# the legion-private oh-my-pi.nix (omp/ompl/omprp wrappers).
{
  lib,
  pkgs,
  inputs ? null,
}: let
  pin = builtins.fromJSON (builtins.readFile ./_pin.json);
  inherit (pin) version hash;
in
  pkgs.stdenv.mkDerivation {
    pname = "omp";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
      sha256 = hash;
    };

    dontUnpack = true;
    dontBuild = true;
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

    passthru.updateScript = ./_update.sh;

    meta = {
      description = "Oh-My-Pi (omp) agent harness, upstream release binary";
      homepage = "https://github.com/can1357/oh-my-pi";
      license = lib.licenses.mit;
      mainProgram = "omp";
      platforms = ["x86_64-linux"];
    };
  }
