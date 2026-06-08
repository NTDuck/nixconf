{
  flake.modules.nixos.dev-toolchains = {
    pkgs, ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.python3
      pkgs.unstable.python3Packages.pip
      pkgs.unstable.python3Packages.virtualenv
    ];
  };

  flake.modules.homeManager.dev-toolchains = {
    pkgs, ... 
  }: {
    programs.poetry = {
      enable = true;
      package = pkgs.unstable.poetry;
    };

    programs.uv = {
      enable = true;
      package = pkgs.unstable.uv;
    };
  };
}