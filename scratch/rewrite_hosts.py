import os

aspects = [f.replace(".nix", "") for f in os.listdir("den/v1/modules/features") if f.endswith(".nix") and f != "default.nix"]
# for subdirectories
for d in os.listdir("den/v1/modules/features"):
    if os.path.isdir(os.path.join("den/v1/modules/features", d)):
        aspects.append(d)

for host in ["dell-latitude-E7270-H836QF2", "lenovo-legion-pro-16-iah7h"]:
    path = f"den/v1/hosts/{host}/configuration.nix"
    if not os.path.exists(path): continue
    
    # We write a fresh configuration.nix using den.aspects
    includes = "\n      ".join([f"den.aspects.\"{a}\"" for a in aspects])
    
    content = f"""{{ den, ... }}:
{{
  den.aspects."{host}" = {{
    includes = [
      {includes}
    ];
    nixos = {{ config, lib, pkgs, inputs, ... }}: {{
      imports = [ ./hardware/default.nix ];
      this.hostname = "{host}";
    }};
  }};
}}
"""
    with open(path, "w") as f:
        f.write(content)
