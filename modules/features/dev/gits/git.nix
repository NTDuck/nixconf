{den, ...}: {
  den.aspects.dev.gits.git = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.git
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.git = {
        enable = true;
        package = pkgs.unstable.git;

        settings = {
          alias = {
            # https://trunk.io/blog/git-commit-messages-are-useless
            nccommit = "commit -a --allow-empty-message -m ''";
          };

          # Empty askPass (2026-09-25 user report "git pull opens a GUI
          # window when prompted for credentials"): git's askpass
          # precedence is GIT_ASKPASS > core.askPass > SSH_ASKPASS. With
          # no GIT_ASKPASS/core.askPass set, git fell through to the
          # session's SSH_ASKPASS = x11-ssh-askpass and drew an X window
          # (reproduced on dell: `git credential fill` with that env
          # popped an OpenSSH prompt on :0). core.askPass = "" makes
          # git's exec of the askpass helper fail instantly (empty string
          # is not an executable), so https username/password prompts
          # land in the terminal's git-credential TTY loop instead.
          core.askPass = "";
        };
      };

      # Belt and braces for tools that bypass git config (env var beats
      # core.askPass anyway): an empty GIT_ASKPASS short-circuits the
      # lookup entirely.
      home.sessionVariables.GIT_ASKPASS = "";

      home.extraActivationPath = [
        pkgs.unstable.git
      ];
    };
  };
}
