import sys
import os
import re
import glob

nixos_mods = set()
home_mods = set()

for f in glob.glob("_/modules/nixos/*.nix"):
    nixos_mods.add(os.path.basename(f).replace(".nix", ""))
for f in glob.glob("_/modules/home/*.nix"):
    home_mods.add(os.path.basename(f).replace(".nix", ""))

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    file_basename = os.path.basename(filepath).replace(".nix", "")
    parts = file_basename.split("-")
    if parts[-1] == "default":
        neighbor_prefix = "-".join(parts[:-1]) + "-"
    else:
        neighbor_prefix = "-".join(parts[:-1]) + "-" if len(parts) > 1 else ""

    def replacer(match):
        mtype = match.group(1)
        mname = match.group(2).strip('"') # Remove quotes if present
        
        # strip any existing prefix to re-evaluate
        stripped_name = mname
        for p in ["common-", "dell-", "lenovo-"]:
            if stripped_name.startswith(p):
                stripped_name = stripped_name[len(p):]
                break

        # If it was a nested one, it might have multiple parts
        # e.g. slops-ollama. We want to strip the folder parts too?
        # Actually, let's just try to find the best match.
        
        mods = home_mods if mtype == "home" else nixos_mods
        
        guesses = [
            f"{neighbor_prefix}{stripped_name}",
            f"{neighbor_prefix}{stripped_name}-default",
            f"common-{stripped_name}",
            f"common-{stripped_name}-default",
            mname # Keep original as last resort
        ]
        
        for g in guesses:
            if g in mods:
                return f'self.{mtype}Modules."{g}"'
        
        return f'self.{mtype}Modules."{guesses[0]}"'

    # Match both self.nixosModules.foo and self.nixosModules."foo"
    new_content = re.sub(r'self\.(nixos|home)Modules\.("?[a-zA-Z0-9_\-]+")?', replacer, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for filepath in glob.glob("_/modules/**/*.nix", recursive=True):
    fix_file(filepath)
