{den, ...}: {
  den.aspects.miktex = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.texlive.combined.scheme-full];};
  };
}
