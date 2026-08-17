{den, ...}: {
  den.aspects.productivity.obsidian = {
    homeManager = {pkgs, ...}: {
      programs.obsidian = {
        enable = true;
        package = pkgs.unstable.obsidian;

        defaultSettings = {
          appearance = {
            accentColor = "#ffd700";
          };

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
