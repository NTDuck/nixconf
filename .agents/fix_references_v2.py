import sys
import os
import re
import glob

# Map of old relative paths to new module names
# We'll build this by looking at what we created
migration_map = {}

def build_map():
    # targets/common/aalc.nix -> nixosModules."common-aalc"
    for root, dirs, files in os.walk("targets"):
        for f in files:
            if f.endswith(".nix"):
                full_path = os.path.join(root, f)
                rel_path = os.path.relpath(full_path, "targets")
                mod_name = rel_path.replace(".nix", "").replace("/", "-")
                migration_map[rel_path] = ("nixos", mod_name)
                # also map the directory if it's default.nix
                if f == "default.nix":
                    dir_path = os.path.dirname(rel_path)
                    if dir_path:
                        migration_map[dir_path] = ("nixos", mod_name)

    for root, dirs, files in os.walk("users"):
        for f in files:
            if f.endswith(".nix"):
                full_path = os.path.join(root, f)
                rel_path = os.path.relpath(full_path, "users")
                mod_name = rel_path.replace(".nix", "").replace("/", "-")
                migration_map[rel_path] = ("home", mod_name)
                if f == "default.nix":
                    dir_path = os.path.dirname(rel_path)
                    if dir_path:
                        migration_map[dir_path] = ("home", mod_name)

build_map()

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find self.nixosModules.something or self.homeModules.something
    # and if it's not quoted, it's likely one of our broken ones.
    
    # We need to know what directory the original file was in to resolve relative imports
    # But wait, our migration script ALREADY replaced ./foo with self.nixosModules.foo
    # So we just need to fix those.
    
    def replacer(match):
        mtype = match.group(1) # nixos or home
        mname = match.group(2) # name
        
        # Heuristic: try to find a match in migration_map
        # This is hard because we lost the context of which 'common' it belongs to.
        # However, almost all are in 'common'.
        
        # If it's already got a prefix like 'common-' or 'host-', it might be fine
        if mname.startswith("common-") or mname.startswith("dell-") or mname.startswith("lenovo-"):
             return match.group(0)

        # Try common- prefix
        best_guess = f"common-{mname}"
        # If it was a directory import, it might need -default
        if best_guess not in [v[1] for v in migration_map.values()]:
            if f"{best_guess}-default" in [v[1] for v in migration_map.values()]:
                best_guess = f"{best_guess}-default"
        
        return f'self.{mtype}Modules."{best_guess}"'

    content = re.sub(r'self\.(nixos|home)Modules\.([a-zA-Z0-9_\-]+)', replacer, content)
    
    # Clean up any double quotes or double prefixes
    content = content.replace('""', '"')
    content = content.replace('"common-common-', '"common-')

    with open(filepath, 'w') as f:
        f.write(content)

for filepath in glob.glob("_/modules/**/*.nix", recursive=True):
    fix_file(filepath)
