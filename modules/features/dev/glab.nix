{
  flake.modules.nixos.glab = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.unstable.glab
    ];
  };

  flake.modules.homeManager.glab = {
    pkgs,
    ...
  }: {
    programs.git.settings = {
      credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
    };
  };
}
