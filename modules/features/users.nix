{den, ...}: {
  den.aspects.users = {
    nixos = {
      users.users.ayin = {
        isNormalUser = true;
        group = "users";
        extraGroups = ["wheel"];
      };
    };
  };
}
