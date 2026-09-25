{den, ...}: {
  den.aspects.desktop.greeters.tuigreet = {command}: {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = ''
              ${pkgs.tuigreet}/bin/tuigreet \
              --cmd ${command config} \
              --asterisks --asterisks-char '*' \
              --time --time-format '%Y-%m-%d %H:%M:%S' \
              --remember \
              --container-padding 2 \
            '';
            user = "greeter";
          };
        };
      };

      # X11 is required for the spectrwm session (legion's mango session
      # also works with xserver.enable = true — greetd starts the X
      # server, mango runs as a Wayland client via WLR_NO_HARDWARE=1 in
      # its autostart).
      services.xserver.enable = true;
      console.earlySetup = true;

      # TERMINAL-ONLY credential prompts (2026-09-25 user report: "when
      # pulling git opens GUI window when prompted for credentials").
      # Root cause: services.xserver.enable defaults programs.ssh
      # enableAskPassword to true (nixpkgs programs/ssh.nix:46-51), which
      # exports SSH_ASKPASS=x11-ssh-askpass session-wide. Git's prompt
      # helper falls back to SSH_ASKPASS when no GIT_ASKPASS/core.askPass
      # is set — and x11-ssh-askpass pops an X window (reproduced live:
      # `git -c credential.helper= credential fill` with that env drew an
      # OpenSSH window on :0). This host greets gitlab.viettelsoftware.com
      # over private-network https, so the password prompt IS the git
      # path — force it into the terminal: SSH_ASKPASS = false means
      # git's askpass exec fails instantly and the prompt falls through
      # to the TTY (git-credential's read-credentials loop), which is
      # exactly what a terminal-only session wants. GIT_ASKPASS is unset
      # here because git's askpass precedence is GIT_ASKPASS >
      # core.askPass > SSH_ASKPASS — and the git aspect (features/dev/
      # gits/git.nix) sets GIT_ASKPASS = "" for every user, which is ""
      # = disabled, taking precedence over this SSH_ASKPASS export.
      # mkForce REQUIRED: programs/ssh.nix:406 sets the same
      # environment.variables.SSH_ASKPASS option when
      # programs.ssh.enableAskPassword defaults on via
      # services.xserver.enable — plain definition = eval conflict
      # (reproduced: "conflicting definition values").
      environment.variables.SSH_ASKPASS =
        lib.mkForce "${pkgs.coreutils}/bin/false";
    };
  };
}
