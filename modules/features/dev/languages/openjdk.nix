{den, ...}: {
  den.aspects.openjdk = {
    homeManager = {pkgs, ...}: {programs.java.enable = true;};
  };
}
