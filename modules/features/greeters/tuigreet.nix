{den, ...}: {
  den.aspects.greeters.tuigreet = cmd: {
    nixos = {pkgs, ...}: {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = ''
              ${pkgs.tuigreet}/bin/tuigreet \
              --cmd ${cmd} --no-xsession-wrapper \
              --asterisks --asterisks-char '*' \
              --time --time-format '%Y-%m-%d %H:%M:%S' \
              --remember \
              --container-padding 2 \
            '';
            user = "greeter";
          };
        };
      };

      services.xserver.enable = false;
      console.earlySetup = true;
    };
  };
}
