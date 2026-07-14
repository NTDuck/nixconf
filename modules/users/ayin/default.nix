{den, ...}: {
  den.aspects.ayin = {
    includes = [
      den.batteries.primary-user
      den.aspects.ayin.dev.gits.git
    ];

    provides.to-hosts.nixos = {
      pkgs,
      user,
      ...
    }: {
      users.users.${user.userName} = {
        extraGroups = [
          "adbusers"
          "docker"
          "kvm"
          "libvirtd"
        ];
        shell = pkgs.unstable.zsh;
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
