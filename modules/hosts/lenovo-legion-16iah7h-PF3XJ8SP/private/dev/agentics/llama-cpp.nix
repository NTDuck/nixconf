{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      # llama-cpp is CLI-only now: llama-cli, llama-bench, and llama-server
      # (the CUDA build's --list-devices powers the egpu.nix health probe).
      # All serving goes through services.ollama.
      environment.systemPackages = [
        (pkgs.unstable.llama-cpp.override {cudaSupport = true;})
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
}
