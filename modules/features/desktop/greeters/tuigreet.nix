{
  den,
  lib,
  ...
}: {
  # Session command resolver + optional autologin. `session` is a
  # config -> command-string lambda (the host composes it from its own
  # aspects' options); null = no fixed command, tuigreet lists
  # services.displayManager.sessionPackages with --remember-session
  # (mango registers itself via programs.mango.addLoginEntry).
  # autologin = true adds initial_session: boots straight into `session`
  # as "ayin" (single-user hosts; locking is the session's job, and
  # greetd's restart default flips off automatically — every greetd
  # restart would otherwise re-trigger the autologin).
  den.aspects.desktop.greeters.tuigreet = {
    session ? null,
    autologin ? false,
  }: {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      services.greetd = {
        enable = true;
        # TTY/stdio adjustments so boot messages don't corrupt the TUI.
        useTextGreeter = true;

        settings = {
          default_session.command =
            if session != null
            then let
              flags = "--asterisks --asterisks-char '*' --time --time-format '%Y-%m-%d %H:%M:%S' --remember --container-padding 2";
            in "${pkgs.tuigreet}/bin/tuigreet ${flags} --cmd ${session config}"
            else let
              flags = "--asterisks --asterisks-char '*' --time --time-format '%Y-%m-%d %H:%M:%S' --container-padding 2";
            in "${pkgs.tuigreet}/bin/tuigreet ${flags} --remember-session";

          initial_session = lib.mkIf (session != null && autologin) {
            command = session config;
            user = "ayin";
          };
        };
      };

      console.earlySetup = true;
    };
  };
}
