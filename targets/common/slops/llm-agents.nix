{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.system}.antigravity
    inputs.llm-agents.packages.${pkgs.system}.ralph-tui
    inputs.llm-agents.packages.${pkgs.system}.agent-browser
  ];
}
