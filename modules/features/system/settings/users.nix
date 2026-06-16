{den, ...}: {
  den.aspects.system-users = {
    nixos = {
      users.users.ayin = {
        isNormalUser = true;
        description = "ayin";
        extraGroups = ["networkmanager" "wheel" "adbusers" "kvm"];
      };
      security.sudo.extraConfig = "Defaults timestamp_timeout=-1\nDefaults timestamp_type=tty";
    };
  };
}
