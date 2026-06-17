{den, ...}: {
  den.aspects.topiary = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.topiary

        pkgs.unstable.nickel # .ncl
        pkgs.unstable.ts_query_ls # .scm
      ];
    };
  };
}
