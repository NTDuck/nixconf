{
  den.aspects.glab = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.glab
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.git.settings = {
        credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
      };
    };
  };
}
