{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, hotspot.nix pattern): the CUDA
    # llama-cpp build (+ memlock limits it needs) lives inside
    # specialisation.homelab. Default generation stays CUDA-free.
    nixos = {pkgs, ...}: {
      specialisation.homelab.configuration = {
        # llama-cpp is CLI-only now: llama-cli, llama-bench, and llama-server
        # (the CUDA build's --list-devices powers the egpu/default.nix health probe).
        # All serving goes through services.ollama.
        environment.systemPackages = [
          (pkgs.unstable.llama-cpp.override {
            cudaSupport = true;
            # node is a build-time-only dep (webui `npm run build`, not
            # embedded). Unstable's nodejs_26 (26.9.0) predates the
            # test-fs-cp-async-file-modes sandbox skip (nixpkgs#564449) and
            # fails its own test suite in the Nix sandbox, cascading into this
            # CUDA build; the stable tree's identical 26.9.0 has the skip and
            # is on cache.nixos.org. Keep args in sync with egpu/default.nix.
            nodejs_latest = pkgs.nodejs_26;
          })
        ];

        # memlock pins from the previous setup, kept for the CLI tools: large
        # GGUFs are mmapped by llama-cli / llama-bench and hugepages-backed
        # locking avoids page-outs during long benches.
        security.pam.loginLimits = [
          {
            domain = "*";
            type = "soft";
            item = "memlock";
            value = "infinity";
          }
          {
            domain = "*";
            type = "hard";
            item = "memlock";
            value = "infinity";
          }
        ];

        systemd.settings.Manager.DefaultLimitMEMLOCK = "infinity";
        systemd.user.extraConfig = "DefaultLimitMEMLOCK=infinity";
      };
    };
  };
}
