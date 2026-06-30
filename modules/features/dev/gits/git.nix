{den, ...}: {
  den.aspects.dev.gits.git = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.git
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.git = {
        enable = true;
        package = pkgs.unstable.git;

        settings = {
          alias = {
            nccommit = "commit -a --allow-empty-message -m ''"; # https://trunk.io/blog/git-commit-messages-are-useless
          };
        };
      };

      home.extraActivationPath = [
        pkgs.unstable.git
      ];
    };
  };
}
