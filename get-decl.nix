let
  flake = builtins.getFlake (toString ./.);
  eval = flake.nixosConfigurations.dell-latitude-E7270-H836QF2;
  hm = eval.options.home-manager.users.type.getSubOptions [];
in
  hm.ayin.wayland.windowManager.sway.config.output.declarations
