{den, inputs, ...}: {
  # darling-lol (github:lucannez64/darling-lol) — experimental macOS League
  # client runtime on Linux via Darling. Legion-only.
  #
  # The flake package is ONLY the launcher + FHS dependency environment
  # (cmake/clang/lld/llvm 21, X11, Vulkan, PulseAudio/ALSA, FFmpeg 8 pinned
  # by upstream for its generated AV wrappers, pythonEnv). It ships NO
  # Darling runtime and NO game files: the ~40-50 GiB Darling build and the
  # Riot client install happen per-user in the writable workspace
  # (${XDG_DATA_HOME:-$HOME/.local/share}/darling-lol) during the first
  # interactive `darling-lol` launch. Rebuild/update with `darling-lol
  # --update` after closing the clients.
  #
  # Rootless launcher prerequisites (host-side, all here):
  #   - unprivileged user namespaces (kernel.unprivileged_userns_clone=1;
  #     CachyOS kernel default) with newuidmap/newgidmap setuid wrappers
  #     (NixOS provides both at /run/wrappers/bin out of the box);
  #   - subordinate UID/GID ranges for the user: users.users.ayin
  #     .autoSubUidGidRange = true.
  #
  # Riot/anti-cheat warning (upstream README): launching LoL under Darling
  # is an unsupported environment and has been triggering 3-day
  # "UNSUPPORTED_THIRD_PARTY_TOOLS" suspensions upstream — use a throwaway
  # account, no ranked, at your own risk. Not our call to make, just
  # recorded here.
  den.aspects.apps.gaming.darling-lol = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.darling-lol.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # Rootless user-namespace launcher needs subordinate ID ranges for
      # the unprivileged uid/gid mapping (docs/NIX.md prerequisite).
      # Provenance (verified 2026-11-15): nixpkgs 26.05 defaults
      # autoSubUidGidRange to true for isNormalUser with empty sub ranges
      # (users-groups.nix:496), so /etc/subuid (ayin:100000:65536) exists
      # either way — BUT older branches gate that default on
      # !mutableUsers, and this host has mutableUsers = true. Explicit
      # here so the prerequisite cannot silently regress on a branch
      # bump, same policy as the explicit sudo settings in
      # system.settings.
      users.users.ayin.autoSubUidGidRange = true;
    };
  };
}
