{den, ...}: {
  den.aspects.texlive = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.texliveBasic];};
  };
}
