{den, ...}: {
  den.aspects.dev.gits.glab = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.glab
      ];
    };

    home-manager = {pkgs, ...}: {
      programs.git.settings = {
        credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
      };
    };
  };
}
