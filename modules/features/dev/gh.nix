{
  flake.modules.homeManager.gh = {pkgs, ...}: {
    programs.gh = {
      enable = true;
      package = pkgs.unstable.gh;

      gitCredentialHelper.enable = true;
    };
  };
}
