{den, ...}: {
  den.aspects.miktex = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.texliveBasic];};
  };
}
