{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "opencode" ''
      exec ${pkgs.nodejs}/bin/npx -y opencode-ai@latest "$@"
    '')
  ];
}
