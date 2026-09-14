{den, ...}: {
  den.aspects.apps.office.texlive = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.texliveBasic];};
  };
}
