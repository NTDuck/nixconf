{den, ...}: {
  den.aspects.desktop.greeters.tuigreet = {command}: {
    nixos = {
      config,
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
    };
  };
}
