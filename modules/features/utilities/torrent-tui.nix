{den, ...}: {
  den.aspects.utilities.torrent-tui = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "torrent-tui";

          runtimeInputs = [
            pkgs.unstable.bun
          ];

          text = ''
            exec bunx torrent-tui@latest "$@"
          '';
        })
      ];
    };
  };
}
