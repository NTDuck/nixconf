{ self, inputs, system, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  age.secrets."gemini-default-token".file = "${self}/secrets/gemini-default-token.age";
  age.secrets."groq-default-token".file = "${self}/secrets/groq-default-token.age";
}
