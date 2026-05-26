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

    is_home_file = "/home/" in filepath
    file_basename = os.path.basename(filepath).replace(".nix", "")
    
    parts = file_basename.split("-")
    if parts[-1] == "default":
        neighbor_prefix = "-".join(parts[:-1]) + "-"
    else:
        neighbor_prefix = "-".join(parts[:-1]) + "-" if len(parts) > 1 else ""

    def replacer(match):
        mtype = match.group(1) # nixos or home
        mname = match.group(2) # name
        
        if mname.startswith("common-") or mname.startswith("dell-") or mname.startswith("lenovo-"):
             return match.group(0)

        guess1 = f"{neighbor_prefix}{mname}"
        guess2 = f"common-{mname}"
        
        mods = home_mods if mtype == "home" else nixos_mods
        
        for g in [guess1, f"{guess1}-default", guess2, f"{guess2}-default"]:
            if g in mods:
                return f'self.{mtype}Modules."{g}"'
        
        return f'self.{mtype}Modules."{guess1}"'

    new_content = re.sub(r'self\.(nixos|home)Modules\.([a-zA-Z0-9_\-]+)', replacer, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for filepath in glob.glob("_/modules/**/*.nix", recursive=True):
    fix_file(filepath)
