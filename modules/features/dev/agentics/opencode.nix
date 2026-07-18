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

          model = "llama.cpp/Qwen2.5 Coder Instruct [General 1.5B total]";
          small_model = "llama.cpp/Qwen2.5 Coder Instruct [General 1.5B total]";

          provider = {
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
