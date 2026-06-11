import os
import re

aspects = set()
features_dir = "den/v1/modules/features"

for root, dirs, files in os.walk(features_dir):
    for f in files:
        if f.endswith(".nix"):
            with open(os.path.join(root, f), "r") as file:
                content = file.read()
                # Find den.aspects.<name> =
                matches = re.findall(r'den\.aspects\.([a-zA-Z0-9_-]+)\s*=', content)
                for m in matches:
                    aspects.add(m)

for host in ["dell-latitude-E7270-H836QF2", "lenovo-legion-pro-16-iah7h"]:
    path = f"den/v1/hosts/{host}/configuration.nix"
    if not os.path.exists(path): continue
    
    includes = "\n      ".join([f"den.aspects.\"{a}\"" for a in sorted(aspects)])
    
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
