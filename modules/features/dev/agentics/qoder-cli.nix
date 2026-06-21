{
  den,
  inputs,
  ...
}: {
  den.aspects.qoder-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.qoder-cli
      ];
    };
  };
}
