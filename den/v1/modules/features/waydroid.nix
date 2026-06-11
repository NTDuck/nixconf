{ den, inputs ? {}, ... }@flakeArgs:
let
  old = import ../../../../modules/features/waydroid.nix;
  
  oldEval = if builtins.isFunction old then old flakeArgs else old;
  
  extract = class: 
    if builtins.hasAttr "flake" oldEval && builtins.hasAttr "modules" oldEval.flake && builtins.hasAttr class oldEval.flake.modules then
      builtins.head (builtins.attrValues oldEval.flake.modules."${class}")
    else
      {};
      
  wrap = inner:
    if builtins.isFunction inner then
      {
        __functor = self: args: inner (args // { inherit inputs; });
        __functionArgs = builtins.functionArgs inner;
      }
    else
      inner;
      
  nixosMod = wrap (extract "nixos");
  hmMod = wrap (extract "homeManager");
in
{
  den.aspects."waydroid" = {
    nixos = nixosMod;
    homeManager = hmMod;
  };
}
