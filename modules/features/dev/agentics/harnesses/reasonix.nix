{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.agentics.harnesses.reasonix = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.reasonix
      ];
    };
  };
}
