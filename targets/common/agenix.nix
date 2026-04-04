{ self, inputs, system, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets."gemini-default-token".file = "${self}/secrets/gemini-default-token.age";
  age.secrets."groq-default-token".file = "${self}/secrets/groq-default-token.age";
}
