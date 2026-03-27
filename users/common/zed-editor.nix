{ lib, pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    # https://github.com/zed-industries/zed/issues/32792
    package = pkgs.symlinkJoin {
      name = "zed-xwayland";
      paths = [ pkgs.zed-editor ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/zeditor \
          --unset WAYLAND_DISPLAY
      '';
    };

    extensions = [
      # "catppuccin-blur"
      "catppuccin-icons"

      "nix"
    ]; # https://github.com/zed-industries/extensions/tree/main/extensions

    userSettings = {
      features.copilot = false;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      session.trust_all_worktrees = true;
      base_keymap = "VSCode";

      buffer_font_size = lib.mkForce 11;
      ui_font_size = lib.mkForce 11;

      icon_theme = lib.mkForce "Catppuccin Latte";
    };
  };

  home.packages = [
    pkgs.nil
    pkgs.nixd
  ];

  programs.zsh.shellAliases = {
    zed = "zeditor";
  };
}
