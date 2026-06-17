{den, ...}: {
  den.aspects.miktex = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.texlive.combined.scheme-full];};
  };
}
