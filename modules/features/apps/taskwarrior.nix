{den, ...}: {
  den.aspects.apps.taskwarrior = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.taskwarrior-tui
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.taskwarrior = {
        enable = true;
        # nixpkgs-unstable taskwarrior3 3.5.0: links -lsqlite3 but omits
        # sqlite from buildInputs (link fails: cannot find -lsqlite3).
        # pinned to rev f4a03c008967841f2a0b3cb7c436fc6fc31671f6
        package = pkgs.unstable.taskwarrior3.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
          buildInputs = (old.buildInputs or []) ++ [ pkgs.unstable.sqlite ];
          # corrosion's CMake link step drops NIX_LDFLAGS — force -lsqlite3
          # into the final link (taskchampion's libsqlite3-sys expects the
          # system lib; cargo-setup-hook sets LIBSQLITE3_SYS_USE_PKG_CONFIG=1).
          env = (old.env or {}) // { NIX_LDFLAGS_AFTER = "-lsqlite3"; };
        });
      };

      home.shellAliases = {
        tt = "${pkgs.unstable.taskwarrior-tui}/bin/taskwarrior-tui";
      };
    };
  };
}
