{inputs, ...}: {
  flake.modules.homeManager.helix = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.helix = {
      enable = true;
      package = pkgs.unstable.helix;

      defaultEditor = true;

      settings = {
        editor = {
          soft-wrap.enable = true;
        };
      };

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
      };
    };
  };
}
