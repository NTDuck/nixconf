{
  flake.modules.nixos.antigravity-usage = {pkgs, ...}: {
    # environment.systemPackages = [
    #   pkgs.unstable.nodejs
    #   pkgs.unstable.nodePackages.antigravity-usage
    # ];
  };

  flake.modules.homeManager.antigravity-usage = {pkgs, ...}: {
    # home.shellAliases = {
    #   agy-u = "${pkgs.unstable.nodePackages.antigravity-usage}/bin/antigravity-usage";
    # };
  };
}
