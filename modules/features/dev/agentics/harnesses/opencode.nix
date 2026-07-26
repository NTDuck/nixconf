{den, ...}: {
  den.aspects.dev.agentics.opencode = {
    homeManager = {pkgs, ...}: {
      programs.opencode = {
        enable = true;
        package = pkgs.unstable.opencode;

        extraPackages = [
          pkgs.unstable.fd
          pkgs.unstable.git
          pkgs.unstable.jq
          pkgs.unstable.ripgrep
        ];

        settings = {
          autoshare = false;
          autoupdate = false;
        };
      };
    };
  };
}
