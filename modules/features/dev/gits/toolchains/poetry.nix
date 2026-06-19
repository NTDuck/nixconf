{den, ...}: {
  den.aspects.poetry = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.poetry];};
  };
}
