{
  flake.modules.homeManager.taskwarrior = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.taskwarrior = {
      enable = true;
      package = pkgs.unstable.taskwarrior3;
    };

    home.packages = [
      pkgs.unstable.taskwarrior-tui
    ];

    programs.zsh.shellAliases = {
      tt = "taskwarrior-tui";
    };
  };
}
