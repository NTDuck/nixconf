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

          model = "llama.cpp/Qwen2.5 Coder [3B]";
          small_model = "llama.cpp/Qwen2.5 Coder [3B]";

          provider = {
            colibri = {
              npm = "@ai-sdk/openai-compatible";
              name = "colibri [local]";
              options = {
                apiKey = "none";
                baseURL = "http://127.0.0.1:8000/v1";
                timeout = 1200000;
                chunkTimeout = 120000;
              };
              models = {
                glm-5_2-colibri = {
                  name = "GLM 5.2 [744B]";
                  limit = {
                    context = 4096;
                    output = 1024;
                  };
                };
              };
            };

            "llama.cpp" = {
              npm = "@ai-sdk/openai-compatible";
              name = "llama.cpp [local]";
              options = {
                apiKey = "none";
                baseURL = "http://127.0.0.1:8080/v1";
                timeout = 600000;
                chunkTimeout = 60000;
              };
            };
          };
        };
      };
    };
  };
}
