import sys
import os
import re

def migrate_file(filepath, out_dir, is_home):
    with open(filepath, 'r') as f:
        content = f.read().strip()

    # Determine module type and name
    module_type = "homeModules" if is_home else "nixosModules"
    rel_path = os.path.relpath(filepath, "users" if is_home else "targets")
    mod_name = rel_path.replace(".nix", "").replace("/", "-")
    
    # Prefix for sibling modules
    prefix = "-".join(mod_name.split("-")[:-1])
    if prefix: prefix += "-"

    # Replace relative imports: ./foo -> self.nixosModules."prefix-foo"
    # We match ./foo or ./foo/default.nix
    def replace_import(match):
        import_path = match.group(1)
        name = import_path[2:].replace('.nix', '').replace('/default', '').strip('/')
        if name == '': # just ./
             # This is tricky, usually means current directory (default.nix)
             # But if we are in default.nix importing ./slops, name is 'slops'
             return match.group(0)
        
        # If it ends in -default, we might need to append it if it's a directory
        # But for now let's just use the name as is
        full_mod_name = f"{prefix}{name}"
        # Some special cases like ./zsh when zsh is a dir with default.nix
        # The new name will be common-zsh-default. 
        # So we check if the target is likely a directory.
        target_path = os.path.join(os.path.dirname(filepath), import_path)
        if os.path.isdir(target_path):
            full_mod_name += "-default"
        
        return f'self.{module_type}."{full_mod_name}"'

    # Improved regex for ./ imports, avoiding things like "${self}/..."
    # We look for something that starts with ./ and is inside [ ] or follows imports =
    # Actually let's just look for any ./ that is not preceded by ${ or /
    # But wait, Nix uses ./foo as a path literal.
    
    # Let's just find all ./ expressions that are likely Nix imports
    # They are usually followed by space, newline, or ; or ]
    new_content = re.sub(r'(?<!\$\{)(?<!/)\./([a-zA-Z0-9_\-\./]+)', replace_import, content)

    # Wrap it
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
