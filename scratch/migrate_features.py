import os

features_dir = "modules/features"
system_dir = "modules/system"
out_dir = "den/v1/modules/features"

os.makedirs(out_dir, exist_ok=True)

for src_dir in [features_dir, system_dir]:
    for root, dirs, files in os.walk(src_dir):
        for f in files:
            if f.endswith(".nix"):
                if f == "default.nix":
                    feature_name = os.path.basename(root)
                else:
                    feature_name = f.replace(".nix", "")
                
                # Make a distinct filename for default.nix so we don't overwrite
                if f == "default.nix":
                    out_f = feature_name + "-default.nix"
                else:
                    out_f = f
                
                with open(os.path.join(root, f), "r") as src:
                    content = src.read()
                
                # very simple wrapper for now
                out_content = f"""{{ den, ... }}:
{{
  den.aspects.{feature_name} = {{
    nixos = {{ pkgs, ... }}: {{
      imports = [ ../../../{os.path.relpath(os.path.join(root, f), "den/v1")} ];
    }};
    homeManager = {{ pkgs, ... }}: {{
      imports = [ ../../../{os.path.relpath(os.path.join(root, f), "den/v1")} ];
    }};
  }};
}}
"""
                with open(os.path.join(out_dir, out_f), "w") as out:
                    out.write(out_content)
