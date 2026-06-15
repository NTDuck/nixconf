{
  den,
  inputs,
  ...
}: {
  den.aspects.agent-browser = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.agent-browser
      ];
    };
  };
}
