{
  flake.modules.nixos.qoder-cli = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.qoder-cli
    ];
  };
}
