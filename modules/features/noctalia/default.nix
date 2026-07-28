{
  den,
  inputs,
  ...
}: {
  den.aspects.noctalia = {
    includes = [
      den.aspects.utilities.quickshell

      # https://docs.noctalia.dev/v4/getting-started/nixos/#:~:text=Caution
      den.aspects.settings.networking
      den.aspects.bluetooth
      den.aspects.battery.power-profiles-daemon
      den.aspects.battery.upower
    ];

    nixos = {
      # https://docs.noctalia.dev/v4/getting-started/nixos/?section=binary-cache#binary-cache
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    # homeManager = {pkgs, ...}: {
    #   imports = [
    #     inputs.noctalia.homeModules.default
    #   ];

    #   programs.noctalia = {
    #     enable = true;
    #     package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    #       # The upstream package's test targets currently fail late in the Nix
    #       # Meson build on this pin; Noctalia itself builds and runs without them.
    #       mesonFlags =
    #         (old.mesonFlags or [])
    #         ++ [
    #           "-Dtests=disabled"
    #         ];
    #     });
    #     settings =
    #       builtins.replaceStrings
    #       ["\${inputs.self}"]
    #       ["${inputs.self}"]
    #       (builtins.readFile "${inputs.self}/modules/features/noctalia/noctalia-config.toml");
    #   };
    # };

    homeManager = {pkgs, ...}: {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia-shell = {
        enable = true;

        package =
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
          (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                provider="Modules/Panels/Launcher/Providers/ApplicationsProvider.qml"

                # Terminal applications.
                substituteInPlace "$provider" \
                  --replace-fail \
                    'CompositorService.spawn(command);' \
                    'Quickshell.execDetached(command);'

                # Ordinary desktop applications.
                substituteInPlace "$provider" \
                  --replace-fail \
                    'CompositorService.spawn(app.command);' \
                    'Quickshell.execDetached(app.command);'
              '';
          });

        # TODO Settings
      };
    };
  };
}
