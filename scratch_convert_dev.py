import os
import re

src_dir = "/home/ayin/projs/nixconf/modules/features/dev"
dst_dir = "/home/ayin/projs/nixconf/den/v1/modules/features/dev"

def convert_file(src, dst):
    with open(src, "r") as f:
        content = f.read()

    # We need to transform:
    # flake.modules.nixos.alejandra = {pkgs, ...}: { ... };
    # into
    # den.aspects.alejandra = { nixos = {pkgs, ...}: { ... }; };
    
    # We might have both nixos and homeManager in the same file.
    # Actually, the simplest way is to manually do the mapping or use regex carefully.
    
    # regex to find modules
    # pattern: flake\.modules\.(nixos|homeManager)\.([a-zA-Z0-9_-]+)\s*=\s*(\{.*?\}:)\s*(\{.*)
    # wait, {} might be nested. 
    pass
