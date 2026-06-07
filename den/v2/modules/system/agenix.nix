{
  flake.modules.nixos.agenix = {
    pkgs,
    config,
    lib,
    inputs, ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    imports = [
      inputs.agenix.nixosModules.default
    ];

    environment.systemPackages = [inputs.agenix.packages.${pkgs.system}.default];

    age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    age.secrets."gemini-default-token".file = "${inputs.self}/secrets/gemini-default-token.age";
    age.secrets."groq-default-token".file = "${inputs.self}/secrets/groq-default-token.age";
    age.secrets."github-token".file = "${inputs.self}/secrets/github-token.age";

    nix.extraOptions = ''
      !include ${config.age.secrets."github-token".path}
    '';
  };
  flake.modules.homeManager.agenix = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];

    age.identityPaths = ["/home/ayin/.ssh/id_ed25519"];

    age.secrets."gemini-default-token".file = "${inputs.self}/secrets/gemini-default-token.age";
    age.secrets."groq-default-token".file = "${inputs.self}/secrets/groq-default-token.age";
  };
}
