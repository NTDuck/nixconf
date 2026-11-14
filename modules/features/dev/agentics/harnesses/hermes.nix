# hermes agent (NousResearch) — harness aspect.
#
# CLI-only install: the default flake package ships every optional
# dependency group (messaging, voice, anthropic, bedrock, ...), which
# matters because lazy runtime installs cannot write into the sealed
# uv2nix /nix/store venv. The upstream NixOS/HM service modules (gateway
# daemon, Nix-generated config.yaml) are deliberately NOT used: provider
# keys and `hermes setup` stay interactive in ~/.hermes, like every
# other harness here.
{
  den,
  inputs,
  ...
}: {
  den.aspects.dev.agentics.harnesses.hermes = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
