{
  flake.modules.homeManager.antigravity-usage = {pkgs, ...}: {
    home.packages = [pkgs.unstable.nodejs];
    home.shellAliases = {
      agy-u = "npx -y antigravity-usage";
    };
  };
}
