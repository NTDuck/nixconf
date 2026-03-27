{ pkgs, ... }:

{
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

      padding-top = 20;
      padding-bottom = 20;
      padding-left = 20;
      padding-right = 20;
    };
  };
}
