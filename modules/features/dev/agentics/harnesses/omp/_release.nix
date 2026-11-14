# omp release binary (2026-11-14): upstream can1357/oh-my-pi ships a
# glibc-linked bun single-file executable per GitHub release
# (omp-linux-x64, only libc/libm/libpthread/libdl per ldd).
#
# AUTO-PIN (2026-11-14): version and hash are DERIVED from two flake
# inputs (declared in flake.nix, re-locked by `nh os switch ... --update`)
# instead of the 2026-11-09 hand-edited literals:
#   inputs.omp-atom — releases.atom; FIRST entry <id> = latest tag
#     (pinned to the first occurrence: release notes inside <content>
#     could echo "Repository/.../v..." strings, so we split on the full
#     "<id>tag:github.com,2008:Repository/" literal and read what follows).
#   inputs.omp-sums — SHA256SUMS.txt of the LATEST release; the
#     omp-linux-x64 line (line-anchored match, unique per line — musl/
#     arm/darwin variants differ) taken raw-hex; fetchurl accepts
#     "sha256:<hex>" directly.
# A bump is therefore a lock refresh only — no file edits. Skew window:
# atom and sums lock seconds apart during --update; a release landing
# between them fails the fetchurl hash check LOUDLY (older tag + newer
# sums) — rerun --update to heal. releases.atom includes prereleases,
# so --update follows any tag newer than the current stable (accepted
# 2026-11-14 tradeoff).
#
# HISTORY (2026-11-09): hand-pinned literals replaced the llm-agents
# source build (~10min bun+cargo per bump) with a download-only bump;
# 2026-11-14 removed the remaining manual step (the pin edit) per user
# request for --update-only bumps.
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
  inputs,
}: let
  # --- version: latest tag from releases.atom (first <entry>) ---
  atom = builtins.readFile inputs.omp-atom;
  firstEntry = builtins.elemAt (builtins.split "<entry>" atom) 2;
  # Two-step slice: everything before the FIRST </id> of the first entry
  # is exactly "<id>tag:github.com,2008:Repository/<repo-id>/<tag>".
  # (builtins.match is full-string + greedy: a bare .*(…)pattern would
  # match the LAST entry's id, not the first — split first, then match.)
  tag = let
    m = builtins.match ".*Repository/[0-9]+/(v[0-9.]+)" (builtins.head (builtins.split "</id>" firstEntry));
  in
    assert m != null; # feed format change → loud, not silent
    builtins.head m;
  version = builtins.substring 1 (builtins.stringLength tag - 1) tag;

  # --- hash: omp-linux-x64 sha256 from the latest release's sums ---
  sums = builtins.readFile inputs.omp-sums;
  # Line-based parse, NOT one big regex: Nix ECMAScript `.` can't cross
  # \n and $-vs-trailing-newline under std::regex_match is fragile. The
  # anchor "ends with omp-linux-x64" is unique per line — musl/arm/darwin
  # variants differ.
  hexHash = let
    # builtins.splitLines does NOT exist on Lix 2.94 — lib.splitString
    # instead; strip \r in case upstream ever ships CRLF (LF verified
    # 2026-11-14).
    lines = builtins.filter (l: l != "") (map (l: lib.removeSuffix "\r" l) (lib.splitString "\n" sums));
    matches = builtins.filter (l: builtins.match "[0-9a-f]{64}[ \t]+omp-linux-x64" l != null) lines;
    line = builtins.head matches;
  in
    assert builtins.length matches == 1; # sums format change → loud
    builtins.substring 0 64 line;

  # fetchurl accepts `sha256:<64hex>` directly (verified 2026-11-14
  # against a local file) — no base64 conversion needed. NOTE: the
  # 26.05 lib's convertHash is an alias to builtins.convertHash, which
  # Lix 2.94 REMOVED, so lib.convertHash is uncallable here.
  hash = "sha256:${hexHash}";
in
  pkgs.stdenv.mkDerivation {
    pname = "omp";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/${tag}/omp-linux-x64";
      sha256 = hash;
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
  }
