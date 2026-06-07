{inputs, ...}: {
  flake.modules.homeManager.taskwarrior = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
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
