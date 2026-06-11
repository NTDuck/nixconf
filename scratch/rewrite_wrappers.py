import os
import glob
import re

for path in glob.glob("den/v1/modules/features/**/*.nix", recursive=True):
    with open(path, "r") as f:
        content = f.read()

    m = re.search(r'den\.aspects\."?([a-zA-Z0-9_-]+)"?\s*=', content)
    if not m: continue
    feature = m.group(1)

    m = re.search(r'old\s*=\s*import\s*(.*?\.nix)', content)
    if not m: continue
    original_path = m.group(1)

    new_content = f"""{{ den, inputs ? {{}}, ... }}@flakeArgs:
let
  old = import {original_path};
  
  oldEval = if builtins.isFunction old then old flakeArgs else old;
  
  extract = class: 
    if builtins.hasAttr "flake" oldEval && builtins.hasAttr "modules" oldEval.flake && builtins.hasAttr class oldEval.flake.modules then
      builtins.head (builtins.attrValues oldEval.flake.modules."${{class}}")
    else
      {{}};
      
  wrap = inner:
    if builtins.isFunction inner then
      {{
        __functor = self: args: inner (args // {{ inherit inputs; }});
        __functionArgs = builtins.functionArgs inner;
      }}
    else
      inner;
      
  nixosMod = wrap (extract "nixos");
  hmMod = wrap (extract "homeManager");
in
{{
  den.aspects."{feature}" = {{
    nixos = nixosMod;
    homeManager = hmMod;
  }};
}}
"""
    with open(path, "w") as f:
        f.write(new_content)
