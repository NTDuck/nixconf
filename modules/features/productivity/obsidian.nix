{den, ...}: {
  den.aspects.productivity.obsidian = {
    homeManager = {pkgs, ...}: {
      programs.obsidian = {
        enable = true;
        package = pkgs.unstable.obsidian;
      };
    };
  };
}
