{
  flake.modules.nixos.antigravity-cli = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
    ];

    # TODO Make YOLO default
  };
}
