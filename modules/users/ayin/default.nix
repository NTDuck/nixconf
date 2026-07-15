{den, ...}: {
  den.aspects.ayin = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      den.aspects.ayin.dev.gits.git
    ];

    provides.to-hosts.nixos = {user, ...}: {
      users.users.${user.userName} = {
        extraGroups = [
          "adbusers"
          "docker"
          "kvm"
          "libvirtd"
        ];
      };

      security.sudo.extraRules = [
        {
          users = [user.userName];
          commands = [
            {
              command = "/run/current-system/specialisation/light-mode/activate";
              options = ["NOPASSWD"];
            }
            {
              command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
