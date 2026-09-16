# Sunshine is the game-stream HOST: the Legion streams its display to Moonlight clients.
# Ports per https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/guide.html
# (openFirewall covers TCP 47984/47989/47990/48010 + UDP 47998-48000/48010; the explicit
# firewall entries are belt-and-suspenders for setups that also need UDP 48010 control).
# KMS capture needs cap_sys_admin; the nixpkgs sunshine wrapper sets that up already.
{den, ...}: {
  den.aspects.apps.network.sunshine = {
    nixos = {pkgs, ...}: {
      services.sunshine = {
        enable = true;
        package = pkgs.unstable.sunshine;
        openFirewall = true;
      };

      networking.firewall.allowedTCPPorts = [47984 47989 47990 48010];
      networking.firewall.allowedUDPPorts = [47984 47989 47990 47998 47999 48000 48010];
    };

    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.unstable.sunshine
      ];
    };
  };
}
