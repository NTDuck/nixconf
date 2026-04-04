{ osConfig, pkgs, ... }:

{
  programs.opencode = {
    enable = true;

    package = pkgs.symlinkJoin {
      name = "opencode";
      paths = [ pkgs.unstable.opencode ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/opencode \
          --run 'export GROQ_API_KEY=$(cat ${osConfig.age.secrets."groq-default-token".path})' \
          --run 'export GOOGLE_GENERATIVE_AI_API_KEY=$(cat ${
            osConfig.age.secrets."gemini-default-token".path
          })'
      '';
    };

    settings = {
      model = "g4f/auto";

      provider = {
        g4f = {
          npm = "@ai-sdk/openai-compatible";
          name = "GPT4Free";
          options = {
            baseURL = "http://127.0.0.1:1337/v1";
            apiKey = "sk-";
          };
          models = {
            auto = {
              name = "GPT4Free Auto";
            };
            gpt-4 = {
              name = "GPT4Free GPT-4";
            };
          };
        };
        groq = {
          npm = "@ai-sdk/groq";
          name = "Groq";
        };
        google = {
          npm = "@ai-sdk/google";
          name = "Google Gemini";
        };
      };
    };
  };
}
