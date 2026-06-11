{
  den.aspects."qoder-cli" = {
    nixos = {
      pkgs,
      inputs,
      ...
    }: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.qoder-cli
      ];
    };
  };
}
