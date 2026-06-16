{
  den,
  inputs,
  ...
}: {
  den.aspects.zathura = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.zathura
      ];
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.zathura = {
        enable = true;
        package = pkgs.unstable.zathura;

        options = {
          selection-clipboard = "clipboard";
          recolor = true;
        };
      };
    };
  };
}
