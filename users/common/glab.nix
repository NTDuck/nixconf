{pkgs, ...}: {
  home.packages = [
    pkgs.unstable.glab
  ];

  programs.git.settings = {
    credential."https://gitlab.com".helper = "!${pkgs.unstable.glab}/bin/glab auth git-credential";
  };
}
