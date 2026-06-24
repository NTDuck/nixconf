{den, ...}: {
  den.aspects.taskwarrior = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.taskwarrior-tui
      ];
    };

    home-manager = {pkgs, ...}: {
      programs.taskwarrior = {
        enable = true;
        package = pkgs.unstable.taskwarrior3;
      };

      home.shellAliases = {
        tt = "${pkgs.unstable.taskwarrior-tui}/bin/taskwarrior-tui";
      };
    };
  };
}
