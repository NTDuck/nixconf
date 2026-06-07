{
  inputs,
  config,
  ...
}: {
  flake.modules.homeManager.antigravity-usage = {pkgs, ...}: {
    home.packages = [pkgs.nodejs];
    home.shellAliases = {
      agy-u = "npx -y antigravity-usage";
    };
  };
}
