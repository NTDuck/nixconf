import sys
import os
import re
import glob

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Determine if it's a nixos or home module
    is_home = "/home/" in filepath
    prefix = "common-" if "common-" in os.path.basename(filepath) else ""
    
    # This is tricky because we don't know exactly what the prefix should be 
    # just by the current file. 
    # But for common-default.nix, all its imports are in the same 'common' folder.
    
    if "common-default.nix" in filepath:
        if is_home:
            # self.homeModules.slops -> self.homeModules."common-slops-default"
            content = content.replace('self.homeModules.slops', 'self.homeModules."common-slops-default"')
            content = content.replace('self.homeModules.zsh', 'self.homeModules."common-zsh-default"')
            # self.homeModules.agenix -> self.homeModules."common-agenix"
            content = re.sub(r'self\.homeModules\.([a-zA-Z0-9_\-]+)', r'self.homeModules."common-\1"', content)
        else:
            content = content.replace('self.nixosModules.slops', 'self.nixosModules."common-slops-default"')
            content = re.sub(r'self\.nixosModules\.([a-zA-Z0-9_\-]+)', r'self.nixosModules."common-\1"', content)

    # Clean up any double "common-common-"
    content = content.replace('"common-common-', '"common-')
    
    with open(filepath, 'w') as f:
        f.write(content)

for filepath in glob.glob("_/modules/**/*.nix", recursive=True):
    fix_file(filepath)
