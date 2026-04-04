{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;

    settings = {
      model = "g4f/qwen-2.5-coder-32b";
      provider = {
        g4f = {
          npm = "@ai-sdk/openai-compatible";
          name = "GPT4Free";
          options = {
            baseURL = "http://127.0.0.1:1337/v1";
            apiKey = "";
          };
          models = {
            "qwen-2.5-coder-32b" = {
              name = "Qwen 2.5 Coder 32B";
            };
            deepseek-coder = {
              name = "DeepSeek Coder";
            };
            "llama-3.3-70b" = {
              name = "Llama 3.3 70B";
            };
            gpt-4o-mini = {
              name = "GPT-4o Mini";
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
