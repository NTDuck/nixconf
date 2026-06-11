{ den, inputs, ... }: {
  den.aspects."mpv".homeManager = {pkgs, ...}: {
    programs.mpv = {
      enable = true;
      package = pkgs.unstable.mpv;
    };
  };
}
