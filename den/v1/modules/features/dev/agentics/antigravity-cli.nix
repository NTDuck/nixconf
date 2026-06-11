{
  den.aspects."antigravity-cli" = {
    nixos = {
      pkgs,
      inputs,
      ...
    }: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      ];

      # TODO Make YOLO default
    };
  };
}
