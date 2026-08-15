{
  den,
  inputs,
  ...
}: {
  den.aspects.noctalia = {
    includes = [
      # https://docs.noctalia.dev/noctalia/getting-started/nixos/#:~:text=Caution
      den.aspects.settings.networking
      den.aspects.bluetooth
      den.aspects.battery.power-profiles-daemon
      den.aspects.battery.upower
    ];

    nixos = {
      # https://docs.noctalia.dev/noctalia/getting-started/nixos/?section=binary-cache#binary-cache
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;

        settings = {
          bar.default = {
            shadow = false;
            contact_shadow = false;
          };

          dock.shadow = false;
          shell.panel.shadow = false;
        };
      };
    };
  };
}
