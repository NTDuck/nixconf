{ den, inputs, ... }: {
  den.aspects."taskwarrior".nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.unstable.taskwarrior-tui
    ];
  };

  den.aspects."taskwarrior".homeManager = {pkgs, ...}: {
    programs.taskwarrior = {
      enable = true;
      package = pkgs.unstable.taskwarrior3;
    };

    home.shellAliases = {
      tt = "taskwarrior-tui";
    };
  };
}
