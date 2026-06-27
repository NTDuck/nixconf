{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.agentics.codegraph = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codegraph
      ];
    };
  };
}
