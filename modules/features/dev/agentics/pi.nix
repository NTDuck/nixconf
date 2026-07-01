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

        defaultProvider = "llama-cpp";
        defaultModel = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M";

        packages = [
          "git:github.com/tmustier/pi-extensions"
          "git:github.com/DietrichGebert/ponytail"
        ];
      };

      home.file.".pi/agent/models.json".text = builtins.toJSON {
        providers = {
          llama-cpp = {
            baseUrl = "http://127.0.0.1:8080/v1";
            api = "openai-completions";
            apiKey = "none";
            models = [
              {
                id = "OmniCoder-9B-Claude-Opus-High-Reasoning-Distill.Q4_K_M";
              }
              {
                id = "Mirage-OpenReasoning-Nemotron-7B.Q4_K_M";
              }
              {
                id = "Qwen3-4B-Function-Calling-Pro";
              }
              {
                id = "IBM-Agentic-Nvidia-Q4_K_M";
              }
              {
                id = "qwen3-4b-function-calling-xlam-unsloth.q4_k_m";
              }
              {
                id = "xLAM-1b-fc-r.Q4_K_M";
              }
            ];
          };
        };
      };
    };
  };
}
