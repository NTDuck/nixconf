{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.gits.git-ai = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.git-ai
      ];
    };
  };
}
