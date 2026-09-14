{den, ...}: {
  den.aspects.apps.multimedia.gallery-dl = {
    homeManager = {pkgs, ...}: {
      programs.gallery-dl = {
        enable = true;
        package = pkgs.unstable.gallery-dl;

        settings = {
          extractor.base-directory = "~/Downloads";
        };
      };
    };
  };
}
