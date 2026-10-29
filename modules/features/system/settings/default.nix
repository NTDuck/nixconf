{den, ...}: {
  den.aspects.system.settings = {
    includes = [
      den.aspects.system.settings.hardware
      den.aspects.system.settings.i18n
      den.aspects.system.settings.networking
      den.aspects.system.settings.time
    ];

    nixos = {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        # experimental-features = ["nix-command" "flakes" "pipe-operators"];
        trusted-users = ["@wheel"];

        # Numtide cache hosts prebuilt binaries for inputs.llm-agents (omp, codegraph,
        # open-code-review). Configured in system.settings so all hosts (including Dell,
        # which imports individual agentic aspects directly) get substituters without building from source.
        extra-substituters = [
          "https://cache.numtide.com"
        ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
        extra-trusted-substituters = [
          "https://cache.numtide.com"
        ];
      };

      # nix.extraOptions = ''
      #   !include ${config.age.secrets."github-personalaccesstoken".path}
      # '';

      # Explicit: wheel sudo must never regress when aspects shuffle.
      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = true;
      security.sudo.extraConfig = ''
        Defaults timestamp_timeout=-1
        Defaults timestamp_type=tty
      '';
    };
  };
}
