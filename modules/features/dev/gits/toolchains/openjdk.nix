{den, ...}: {
  den.aspects.openjdk = {
    homeManager = {pkgs, ...}: {
      programs.java.enable = true;
      programs.java.package = pkgs.unstable.jdk;
    };
  };
}
