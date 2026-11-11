{den, ...}: {
  den.aspects.ayin = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.ayin.dev.gits.git
    ];

    # TTY/greeter sessions have no browser; `true` makes xdg-open a no-op so
    # anything spawning a browser (tailscale auth under sudo, see
    # features/system/network/tailscale.nix) falls through to printing a URL.
    homeManager = {lib, ...}: {
      # mkDefault: hosts with a real browser aspect (legion's zen-browser)
      # override this; TTY-only hosts like DELL keep the no-op.
      home.sessionVariables.BROWSER = lib.mkDefault "true";

      # npm -g installs (prefix=/home/ayin/.npm-global per ~/.npmrc,
      # 2025-09-11) land in .npm-global/bin, which nothing puts on PATH —
      # e.g. agy-auth (npm i -g @fikrilal/agy-auth, 2026-11-11) was
      # installed but unreachable. Declares the bin dir on the session PATH.
      home.sessionPath = ["$HOME/.npm-global/bin"];
    };
  };
}
