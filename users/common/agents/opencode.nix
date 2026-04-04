{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;

    settings = {
      model = "g4f/gpt-4o";
      provider = {
        g4f = {
          npm = "@ai-sdk/openai-compatible";
          name = "GPT4Free";
          options = {
            baseURL = "http://127.0.0.1:1337/v1";
            apiKey = "";
          };
          models = {
            gpt-4o = {
              name = "GPT-4o";
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
