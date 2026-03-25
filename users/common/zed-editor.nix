{ lib, pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "catppuccin-blur"
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

      # theme = {
      #   mode = "system";
      #   light = "Catppuccin Latte (Blur)";
      #   dark = "Catppuccin Expresso (Blur)";
      # };

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
