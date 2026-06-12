{ den, inputs, ... }: {
  den.aspects.antigravityCli = {
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
