{den, ...}: {
  den.aspects.dev.gits.gh = {
    home-manager = {pkgs, ...}: {
      programs.gh = {
        enable = true;
        package = pkgs.unstable.gh;

        gitCredentialHelper.enable = true;
        settings.git_protocol = "https";

        extensions = [
          pkgs.unstable.gh-dash
          pkgs.unstable.gh-eco
        ];
      };
    };
  };
}
