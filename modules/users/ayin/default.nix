{den, ...}: {
  den.aspects.ayin = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.ayin.dev.gits.git
    ];

    # TTY/greeter sessions have no browser; `true` makes xdg-open a no-op so
    # anything spawning a browser (tailscale auth under sudo, see
    # features/apps/network/tailscale.nix) falls through to printing a URL.
    homeManager = {lib, ...}: {
      # mkDefault: hosts with a real browser aspect (legion's zen-browser)
      # override this; TTY-only hosts like DELL keep the no-op.
      home.sessionVariables.BROWSER = lib.mkDefault "true";
    };
  };
}
