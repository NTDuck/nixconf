let
  flake = builtins.getFlake (toString ./.);
  host = flake.nixosConfigurations.lenovo-legion-16iah7h-PF3XJ8SP;
in
host.config.users.users.ayin.extraGroups
