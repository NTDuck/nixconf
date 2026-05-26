import sys
import os
import re

def migrate_file(filepath, out_dir, is_home):
    with open(filepath, 'r') as f:
        content = f.read().strip()

    module_type = "homeModules" if is_home else "nixosModules"
    rel_path = os.path.relpath(filepath, "users" if is_home else "targets")
    mod_name = rel_path.replace(".nix", "").replace("/", "-")
    
    parts = mod_name.split("-")
    prefix = "-".join(parts[:-1])
    if prefix: prefix += "-"

    def replace_import(match):
        name_with_ext = match.group(1)
        name = name_with_ext.replace('.nix', '').replace('/default', '').strip('/')
        if name == '': return match.group(0)
        
        full_mod_name = f"{prefix}{name}"
        
        # Check if it's a directory
        target_path = os.path.join(os.path.dirname(filepath), "./" + name_with_ext)
        if os.path.isdir(target_path):
            full_mod_name += "-default"
        
        return f'self.{module_type}."{full_mod_name}"'

    new_content = re.sub(r'(?<!\$\{)(?<!/)\./([a-zA-Z0-9_\-\./]+)', replace_import, content)

    final_output = f'{{ self, inputs, ... }}:\n{{\n  flake.{module_type}."{mod_name}" = {new_content};\n}}\n'

    out_file = os.path.join(out_dir, mod_name + ".nix")
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, 'w') as f:
        f.write(final_output)

if __name__ == '__main__':
    filepath = sys.argv[1]
    is_home = "users/" in filepath
    out_dir = "_/modules/home/" if is_home else "_/modules/nixos/"
    migrate_file(filepath, out_dir, is_home)
