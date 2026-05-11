{
  self,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.identityPaths = ["/home/ayin/.ssh/id_ed25519"];

  age.secrets."gemini-default-token".file = "${self}/secrets/gemini-default-token.age";
  age.secrets."groq-default-token".file = "${self}/secrets/groq-default-token.age";
}
