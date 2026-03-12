{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
    ];  # https://github.com/zed-industries/extensions/tree/main/extensions

    userSettings = {
      features.copilot = false;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      session.trust_all_worktrees = true;
      base_keymap = "VSCode";
      project_panel.sticky_scroll = false;  # https://github.com/jenslys/zed-catppuccin-blur/tree/c8f493c54220ed6f6bbf722648a1de96f08a983b?tab=readme-ov-file#%EF%B8%8F-recommended-settings
    };
  };

  home.packages = [
    pkgs.nil
    pkgs.nixd
  ];

  programs.zsh.shellAliases = {
    zed = "zeditor";
  };

  catppuccin.zed = {
    enable = true;

    icons = {
      enable = true;
      flavor = "latte";
    };

    italics = true;
  };
}
