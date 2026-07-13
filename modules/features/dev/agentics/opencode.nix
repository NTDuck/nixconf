{den, ...}: {
  den.aspects.dev.agentics.opencode = {
    homeManager = {pkgs, ...}: {
      programs.opencode = {
        enable = true;
        package = pkgs.unstable.opencode;

        extraPackages = [
          pkgs.unstable.fd
          pkgs.unstable.git
          pkgs.unstable.jq
          pkgs.unstable.ripgrep
        ];

        settings = {
          autoshare = false;
          autoupdate = false;

          model = "colibri/glm-5.2-colibri";
          small_model = "llama.cpp/Qwen3-4B-Function-Calling-Pro";

          provider = {
            colibri = {
              npm = "@ai-sdk/openai-compatible";
              name = "Colibri GLM-5.2 (local)";
              options = {
                baseURL = "http://127.0.0.1:8000/v1";
                timeout = 1200000;
                chunkTimeout = 120000;
              };
              models = {
                "glm-5.2-colibri" = {
                  name = "GLM-5.2 Colibri";
                  limit = {
                    context = 131072;
                    output = 32768;
                  };
                };
              };
            };

            "llama.cpp" = {
              npm = "@ai-sdk/openai-compatible";
              name = "llama-server (local)";
              options = {
                baseURL = "http://127.0.0.1:8080/v1";
                timeout = 600000;
                chunkTimeout = 60000;
              };
              models = {
                "Qwen3-4B-Function-Calling-Pro" = {
                  name = "Qwen3 4B Function Calling Pro";
                  limit = {
                    context = 32768;
                    output = 8192;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
