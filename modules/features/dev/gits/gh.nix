{den, ...}: {
  den.aspects.gh = {
    homeManager = {pkgs, ...}: {
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
