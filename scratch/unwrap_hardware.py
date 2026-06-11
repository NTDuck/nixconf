import os
import re

for host in ["dell-latitude-E7270-H836QF2", "lenovo-legion-pro-16-iah7h"]:
    hw_dir = f"den/v1/hosts/{host}/hardware"
    if not os.path.exists(hw_dir): continue
    for f in os.listdir(hw_dir):
        if not f.endswith(".nix") or f == "default.nix": continue
        path = os.path.join(hw_dir, f)
        with open(path, "r") as file:
            content = file.read()
        
        # Regex to strip `flake.modules.nixos.<name> = `
        new_content = re.sub(r'flake\.modules\.nixos\.[^=]+=\s*', '', content)
        # Also remove the outer `{...}: {` if it exists
        new_content = re.sub(r'^\{\.\.\.\}:\s*\{', '', new_content)
        # Remove the closing `}` for the outer wrapper at the end
        new_content = new_content.rsplit('}', 1)[0]
        
        with open(path, "w") as file:
            file.write(new_content)
