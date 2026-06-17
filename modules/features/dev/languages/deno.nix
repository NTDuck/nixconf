{den, ...}: {
  den.aspects.deno = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.deno];};
  };
}
