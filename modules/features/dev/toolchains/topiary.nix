{
  flake.modules.nixos.dev-toolchains = {
    pkgs, ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.topiary

      pkgs.unstable.nickel # .ncl
      pkgs.unstable.ts_query_ls # .scm
    ];
  };
}