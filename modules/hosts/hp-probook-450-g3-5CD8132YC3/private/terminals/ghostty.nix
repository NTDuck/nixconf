{den, ...}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {pkgs, ...}: {
      # Prevent `can't find terminal definition for xterm-ghostty` when `ssh` from host `lenovo-legion-16iah7h-PF3XJ8SP`
      environment.systemPackages = [
        pkgs.ghostty.terminfo
      ];
    };
  };
}
