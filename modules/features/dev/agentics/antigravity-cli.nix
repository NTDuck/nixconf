{
  den,
  inputs,
  ...
}: {
  den.aspects.antigravity-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      ];

      environment.shellAliases = {
        agy = "${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli}/bin/agy --dangerously-skip-permissions";
      };
    };
  };
}
