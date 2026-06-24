{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.agentics.spec-kit = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.spec-kit
      ];
    };
  };
}
