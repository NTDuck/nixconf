{
  flake.modules.nixos.agent-browser = {
    pkgs,
    ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.agent-browser
    ];
  };
}
