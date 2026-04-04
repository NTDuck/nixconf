{ pkgs, ... }:

let
  default-model = "gemini-3-flash-preview"; # https://g4f.dev/docs/providers-and-models
{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
  };

  programs.zsh.shellAliases = {
    opencode-g4f = "OPENAI_API_KEY='' OPENAI_BASE_URL='http://127.0.0.1:1337/v1' OPENAI_MODEL='${default-model}' opencode";
  };
}
