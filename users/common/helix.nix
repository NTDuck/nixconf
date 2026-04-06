{pkgs, ...}: {
  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;

    defaultEditor = true;

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.unstable.alejandra}/bin/alejandra";
            args = ["--quiet"];
          };
          language-servers = ["nixd"];
        }
      ];

      language-server.nixd = {
        command = "${pkgs.unstable.nixd}/bin/nixd";
        config = {
          formatting = {
            command = ["${pkgs.unstable.alejandra}/bin/alejandra" "--quiet"];
          };
        };
      };
    };
  };
}
