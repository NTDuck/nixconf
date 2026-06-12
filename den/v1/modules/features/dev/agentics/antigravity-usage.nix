{ den, inputs, ... }: {
  den.aspects.antigravityUsage = {
    nixos = {pkgs, ...}: {
      # environment.systemPackages = [
      #   pkgs.unstable.nodejs
      #   pkgs.unstable.nodePackages.antigravity-usage
      # ];
    };

    homeManager = {pkgs, ...}: {
      # home.shellAliases = {
      #   agy-u = "${pkgs.unstable.nodePackages.antigravity-usage}/bin/antigravity-usage";
      # };
    };
  };
}
