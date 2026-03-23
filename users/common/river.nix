{ pkgs, ... }:

{
  wayland.windowManager.river = {
    enable = true;

    # settings = {
    #   map.normal = {
    #     "Super Return" = "spawn footclient";
    #     "Super W" = "spawn firefox";
    #     "Super Q" = "close";
    #     "Super Shift E" = "exit";
    #   };
    # };

    # extraConfig = ''
    #   rivertile -view-padding 4 -outer-padding 4 &
    #   yambar &
    #   riverctl background-color 0x111111 &
    #   riverctl spawn "${pkgs.fcitx5}/bin/fcitx5 -d --replace"
    # '';

    extraConfig = ''
      # 1. Start the layout generator! (This fixes the overlapping windows)
      ${pkgs.river}/bin/rivertile -view-padding 4 -outer-padding 4 -main-ratio 0.5 &

      # 2. Start the bar
      ${pkgs.yambar}/bin/yambar &

      # 3. Basic i3-like Keybindings
      riverctl map normal Super Return spawn footclient
      riverctl map normal Super W spawn firefox
      riverctl map normal Super Q close
      riverctl map normal Super Shift E exit
      
      # 4. The Launcher (bemenu)
      riverctl map normal Super Space spawn '${pkgs.bemenu}/bin/bemenu-run -b -p "Run:"'

      # 5. Window Focus (Move between tiled windows)
      riverctl map normal Super J focus-view next
      riverctl map normal Super K focus-view previous

      # 6. i3-like Workspaces (River Tags)
      for i in $(seq 1 9); do
          tags=$((1 << (i - 1)))
          # Switch to workspace (Super + 1..9)
          riverctl map normal Super $i set-focused-tags $tags
          # Move window to workspace (Super + Shift + 1..9)
          riverctl map normal Super+Shift $i set-view-tags $tags
      done

      riverctl spawn "${pkgs.fcitx5}/bin/fcitx5 -d --replace"
    '';
  };
}