{den, ...}: {
  den.aspects.tofi = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.tofi = {
        enable = true;
        package = pkgs.unstable.tofi;

        settings = {
          width = lib.mkForce "100%";
          height = lib.mkForce "100%";
          border-width = lib.mkForce 0;
          outline-width = lib.mkForce 0;
          padding-left = lib.mkForce "35%";
          padding-top = lib.mkForce "35%";
          result-spacing = lib.mkForce 25;
          num-results = lib.mkForce 5;
          font = lib.mkForce "Inter";
          font-size = lib.mkForce 20;
          background-color = lib.mkForce "#000A";
        };
      };
    };
  };
}
