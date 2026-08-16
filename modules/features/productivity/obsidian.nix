{den, ...}: {
  den.aspects.productivity.obsidian = {
    homeManager = {pkgs, ...}: {
      programs.obsidian = {
        enable = true;
        package = pkgs.unstable.obsidian;

        defaultSettings = {
          themes = [
            {
              name = "Typewriter";
              repo = "crashmoney/obsidian-typewriter";
            }
          ];
        };
      };
    };
  };
}
