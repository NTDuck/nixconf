{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.agentics.harnesses.oh-my-pi = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
      ];
    };
  };
}
