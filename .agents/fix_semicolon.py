import sys
import glob

for filepath in glob.glob("_/modules/**/*.nix", recursive=True):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # if it's already ending with ;\n} we skip
    if content.strip().endswith(';}') or content.strip().endswith(';\n}'):
        continue
        
    # Find the last '}' and replace it with '}\n}' or something? 
    # Actually, the file looks like:
    # { self, ... }:
    # {
    #   flake.foo = { ... }: {
    #     ...
    #   }  <-- missing semicolon here
    # }
    
    # We can just do string replacement from the end
    lines = content.split('\n')
    # Find the second to last non-empty line
    # Actually, let's just insert a semicolon before the last `}`
    
    last_brace_idx = content.rfind('}')
    if last_brace_idx != -1:
        new_content = content[:last_brace_idx] + ';\n}' + content[last_brace_idx+1:]
        with open(filepath, 'w') as f:
            f.write(new_content)
