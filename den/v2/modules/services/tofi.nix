{
  flake.modules.homeManager.tofi = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.tofi = {
      enable = true;
      package = pkgs.unstable.tofi;

      settings = {
        width = "50%";
        height = "50%";

        text-cursor-style = "block";
        text-cursor = true;
        matching-algorithm = "fuzzy";

        prompt-text = "$";
        prompt-padding = 10;

        border-width = 2;
        outline-width = 0;

        selection-background = lib.mkForce "#00000000";
        default-result-background = lib.mkForce "#00000000";
        alternate-result-background = lib.mkForce "#00000000";

        padding-top = 20;
        padding-bottom = 20;
        padding-left = 20;
        padding-right = 20;
      };
    };

    home.activation.rm-tofi-cache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD rm -f $HOME/.cache/tofi-drun
    '';
  };
}
