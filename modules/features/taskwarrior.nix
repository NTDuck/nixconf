{
  flake.modules.nixos.taskwarrior = {pkgs, ... }: {
    environment.systemPackages = [
      pkgs.unstable.taskwarrior-tui
    ];
  };

  flake.modules.homeManager.taskwarrior = {
    pkgs,
    ...
  }: {
    programs.taskwarrior = {
      enable = true;
      package = pkgs.unstable.taskwarrior3;
    };

    home.shellAliases = {
      tt = "taskwarrior-tui";
    };
  };
}
