{den, ...}: {
  den.aspects.dev.agentics.pi = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.pi-coding-agent];
    };

    homeManager = {
      home.file.".pi/agent/settings.json".text = builtins.toJSON {
        theme = "dark";
        terminal.showTerminalProgress = true;
        enableInstallTelemetry = false;
        defaultProjectTrust = "always";

        llama-cpp = {
          baseUrl = "http://127.0.0.1:8080/v1";
          api = "openai-completions";
          apiKey = "none";
          models = [
            {
              id = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M";
            }
          ];
        };

        defaultProvider = "llama-cpp";
        defaultModel = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M";

        packages = [
          "git:github.com/tmustier/pi-extensions"
          "git:github.com/DietrichGebert/ponytail"
        ];
      };
    };
  };
}
