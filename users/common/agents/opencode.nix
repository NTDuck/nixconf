{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;

    settings = {
      model = "g4f/auto";
      provider = {
        g4f = {
          npm = "@ai-sdk/openai-compatible";
          name = "GPT4Free Proxy";
          options = {
            baseURL = "http://127.0.0.1:1337/v1";
            apiKey = "sk-dummy";
          };
          models = {
            auto = {
              name = "G4F Auto (Best Available Model/Provider)";
            };
            gpt-4 = {
              name = "GPT-4 (G4F Auto-Routing)";
            };
            "gpt-3.5-turbo" = {
              name = "GPT-3.5 Turbo (G4F Stable Fallback)";
            };
          };
        };
      };
    };
  };

  programs.zsh.shellAliases = {
    g4f-start = "sudo systemctl start docker-g4f";
    g4f-stop = "sudo systemctl stop docker-g4f";
  };
}
