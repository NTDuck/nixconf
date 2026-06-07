{
  flake.modules.nixos.this = {
    options.this = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "default";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "ayin";
      };
    };
  };
  flake.modules.homeManager.this = {
    options.this = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "default";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "ayin";
      };
    };
  };
}
