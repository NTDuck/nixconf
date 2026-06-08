{
  flake.modules.homeManager.kuzu = {
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.unstable.kuzu
    ];
  };
}
