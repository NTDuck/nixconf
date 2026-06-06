import os
import re
from pathlib import Path

targets_dir = Path("D:/_dev/nixconf/targets/common")
users_dir = Path("D:/_dev/nixconf/users/common")
out_dir = Path("D:/_dev/nixconf/den/v1/modules/features")

out_dir.mkdir(parents=True, exist_ok=True)

target_files = {f.name for f in targets_dir.iterdir() if f.is_file() and f.suffix == '.nix'}
user_files = {f.name for f in users_dir.iterdir() if f.is_file() and f.suffix == '.nix'}

all_files = target_files.union(user_files)

def extract_body(path):
    if not path.exists():
        return ""
    content = path.read_text(encoding="utf-8")
    
    # Simple regex to strip `{ pkgs, ... }: {` or `{ config, lib, pkgs, ... }: {` or `let ... in {`
    # Since parsing Nix in Python is hard, we'll use a simplistic balanced brace approach.
    
    # Find the first '{' that opens the main attrset
    # Usually it's after `:`
    idx = content.find(":")
    if idx == -1:
        # maybe it's not a function, just an attrset { ... }
        if content.strip().startswith("{"):
            pass # we'll handle this
    
    # Actually, a better way for a one-off migration is to just indent everything and let Nix parse it.
    pass

def read_and_strip_outer(path):
    if not path.exists():
        return ""
    text = path.read_text(encoding="utf-8").strip()
    # Check if it starts with { args }: {
    m = re.match(r'^\{[^}]*\}\s*(?:@\s*\w+\s*)?:\s*(\{.*)$', text, re.DOTALL)
    if m:
        inner = m.group(1).strip()
        if inner.endswith('}'):
            return inner[1:-1]
    
    # Or let ... in {
    m = re.match(r'^\{[^}]*\}\s*(?:@\s*\w+\s*)?:\s*let.*?in\s*(\{.*)$', text, re.DOTALL)
    if m:
        inner = m.group(1).strip()
        if inner.endswith('}'):
            return inner[1:-1]

    # fallback: just return the text, wait, if we return the text, we can't easily nest it.
    # If we fail to strip, we can just use `imports = [ (import path) ];` but the docs say:
    # "apply the same logic to all other features you find."
    return text # this might be malformed if we just wrap it. We'll refine this.

for file in all_files:
    feature = file[:-4]
    if feature == "sway":
        continue # we will handle sway manually as per docs
        
    t_file = targets_dir / file
    u_file = users_dir / file
    
    t_content = read_and_strip_outer(t_file) if t_file.exists() else ""
    u_content = read_and_strip_outer(u_file) if u_file.exists() else ""
    
    out_text = "{\n"
    if t_content:
        out_text += f"  flake.modules.nixos.{feature} = {{\n{t_content}\n  }};\n"
    if u_content:
        out_text += f"  flake.modules.homeManager.{feature} = {{\n{u_content}\n  }};\n"
    out_text += "}\n"
    
    out_text = "{ inputs, pkgs, config, lib, ... }:\n" + out_text
    
    (out_dir / file).write_text(out_text, encoding="utf-8")

print("Migration script completed.")
