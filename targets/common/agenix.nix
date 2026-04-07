{
  config,
  self,
  inputs,
  system,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = [inputs.agenix.packages.${system}.default];

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  age.secrets."gemini-default-token".file = "${self}/secrets/gemini-default-token.age";
  age.secrets."groq-default-token".file = "${self}/secrets/groq-default-token.age";
  age.secrets."github-token".file = "${self}/secrets/github-token.age";

  nix.extraOptions = ''
    !include ${config.age.secrets."github-token".path}
  '';
}
