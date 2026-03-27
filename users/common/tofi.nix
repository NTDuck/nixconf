{ ... }:

{
  programs.tofi = {
    enable = true;

    settings = {
      width = "50%";
      height = "50%";

      text-cursor-style = "block";

      prompt-text = "$ ";

      border-width = 2;
      # padding-left = "20%";
      # padding-right = "20%";

      text-cursor = true;
      matching-algorithm = "fuzzy";
    };
  };
}
