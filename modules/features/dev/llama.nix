{den, ...}: {
  den.aspects.llama = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.llama-cpp];};
  };
}
