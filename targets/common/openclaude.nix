{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "openclaude" ''
      exec ${pkgs.nodejs}/bin/npx -y @gitlawb/openclaude "$@"
    '')
  ];

  services.ollama = {
    enable = true;
  };
}
