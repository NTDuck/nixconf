{den, ...}: {
  den.aspects.opencode = {
    homeManager = {pkgs, ...}: {
      programs.vscode.enable = true;
      programs.vscode.package = pkgs.unstable.vscode;
    };
  };
}
