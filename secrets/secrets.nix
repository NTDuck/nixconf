let
  # User public keys (allows editing secrets with `agenix -e` without sudo)
  ayin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8xCluYgGb8Zn8LEa+5EnMaqCw1hHV9nNmwdJbDAB1X ayin@lenovo-legion-16iah7h-PF3XJ8SP";
  users = [ayin];

  # System public keys (for host decryption during activation)
  "lenovo-legion-16iah7h-PF3XJ8SP" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMN7o3pdJqi7fPs85aiOytP/VSnts8d8LHmIvxb9tj8j root@lenovo-legion-16iah7h-PF3XJ8SP";
  # "dell-latitude-E7270-H836QF2" = "...";
  systems = [lenovo-legion-16iah7h-PF3XJ8SP];

  mkSecret = secret: {
    name = "${secret}.age";
    value.publicKeys = users ++ systems;
  };
in
  builtins.listToAttrs [
    (mkSecret "github-personalaccesstoken")
    (mkSecret "opencode-api-key")
    (mkSecret "openrouter-api-key")
    (mkSecret "orcarouter-api-key")
    (mkSecret "tabiai-api-key")
    # sk-4m1JIciMBOltWFtRux48HGF7mM6sndD2Fp445PimN75hX7lc
  ]
