{den, ...}: {
  den.aspects.dev.toolchains.sql.mysql = {
    nixos = {pkgs, ...}: {
      # https://nixos.wiki/wiki/Mysql
      services.mysql = {
        enable = true;
        package = pkgs.unstable.mariadb;
      };
    };
  };
}
