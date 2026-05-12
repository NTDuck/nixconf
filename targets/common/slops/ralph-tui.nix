{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.system}.ralph-tui
  ];
}
