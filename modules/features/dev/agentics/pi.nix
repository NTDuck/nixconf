{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.agentics.pi = {
    homeManager = {pkgs, ...}: {
      imports = [
        inputs.pi.homeManagerModules.default
      ];

      programs.pi-coding-agent = {
        enable = true;
        package = pkgs.pi;

        models = {
          # default = {
          #   provider = "openai";
          #   model = "gpt-4o";
          #   apiKey = "$OPENAI_API_KEY"; # reference an env variable
          # };
        };

        # keybindings = {
        #   "mode:main:key:ctrl-p" = ["goto:chat"];
        # };

        extensions = [
          "git:github.com/tmustier/pi-extensions"
          "git:github.com/DietrichGebert/ponytail"
        ];

        # extraEnv = {
        #   OPENAI_API_KEY = "sk-...";
        # };
      };
    };
  };
}
