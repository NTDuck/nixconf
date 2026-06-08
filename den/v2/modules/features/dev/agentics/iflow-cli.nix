{
  flake.modules.nixos.iflow-cli = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.iflow-cli
    ];
  };
}
