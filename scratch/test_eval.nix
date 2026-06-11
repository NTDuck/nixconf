let
  old = import ../modules/features/shell/zsh/default.nix { };
  nixosMod = if old ? flake.modules.nixos then builtins.head (builtins.attrValues old.flake.modules.nixos) else {};
  hmMod = if old ? flake.modules.homeManager then builtins.head (builtins.attrValues old.flake.modules.homeManager) else {};
in
  { inherit nixosMod hmMod; }
