{
  den,
  inputs,
  ...
}: {
  den.aspects.gh = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.gh
        pkgs.unstable.gh-dash
      ];
    };

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
