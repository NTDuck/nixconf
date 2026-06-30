{den, ...}: {
  den.aspects.office.texlive = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.texliveBasic];};
  };
}
