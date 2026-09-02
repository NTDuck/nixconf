{den, ...}: {
  den.aspects.dev.agentics.lmstudio = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lmstudio
      ];

      security.pam.loginLimits = [
        {
          domain = "@users";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@wheel";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
      ];

      systemd.settings.Manager.DefaultLimitMEMLOCK = "infinity";
      systemd.user.extraConfig = "DefaultLimitMEMLOCK=infinity";
    };
  };
}
