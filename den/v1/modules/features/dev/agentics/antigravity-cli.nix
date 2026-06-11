{ den, inputs, ... }: {
  den.aspects."antigravity-cli" = {
    nixos = {
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      ];

      # TODO Make YOLO default
    };
  };
}
