import sys
import os
import re

def migrate_file(filepath, out_dir, module_prefix, is_home):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the first opening brace with args, like { pkgs, ... }: or { ... }:
    # This might span multiple lines
    match = re.search(r'\{[^\}]*\}:', content)
    if not match:
        print(f"Skipping {filepath}, couldn't find args brace.")
        return

    args_block = match.group(0)
    body = content[match.end():]

    # Replace relative imports with self.xxxxModules
    def replace_import(m):
        import_path = m.group(1)
        if import_path.startswith('./'):
            name = import_path[2:].replace('.nix', '').replace('/', '-')
            if name == '':
                return ''
            if is_home:
                return f'self.homeModules.{module_prefix}{name}'
            else:
                return f'self.nixosModules.{module_prefix}{name}'
        return m.group(0)

    # Simple heuristic to find imports block and replace ./sth.nix
    import_pattern = r'(\./[a-zA-Z0-9_\-\./]+(?:\.nix)?)'
    body = re.sub(import_pattern, replace_import, body)

    # Some imports might be a directory, which implicitly imports default.nix.
    # We replaced ./slops with self.nixosModules.targets-common-slops
    # Wait, the original directory had slops/default.nix.
    # Our naming convention will map slops/default.nix to slops-default, so we need to fix this if it occurs.
    # Actually, let's just do a simpler mapping for module names:
    # filepath relative to targets/ or users/
    # e.g., targets/common/slops/default.nix -> targets-common-slops-default

    module_type = "homeModules" if is_home else "nixosModules"
    filename = os.path.basename(filepath)
    rel_path = os.path.relpath(filepath, "targets" if not is_home else "users")
    
    # Create module name
    mod_name = rel_path.replace('.nix', '').replace('/', '-')
    if mod_name.endswith('-default') and mod_name != 'default':
        # we can keep it as -default or strip it. Let's keep it for explicitness
        pass

    mod_name_full = mod_name

    new_content = f"{{ self, inputs, ... }}:\n{{\n  flake.{module_type}.\"{mod_name_full}\" = {args_block}{body}\n}}\n"

    out_file = os.path.join(out_dir, mod_name + ".nix")
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, 'w') as f:
        f.write(new_content)
    print(f"Migrated {filepath} to {out_file} as {module_type}.\"{mod_name_full}\"")

if __name__ == '__main__':
    filepath = sys.argv[1]
    is_home = "users/" in filepath
    out_dir = "_/modules/home/" if is_home else "_/modules/nixos/"
    migrate_file(filepath, out_dir, "", is_home)
