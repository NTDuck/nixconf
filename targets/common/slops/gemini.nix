{pkgs, ...}: {
  programs.gemini-cli = {
    enable = true;
    package = pkgs.unstable.gemini-cli;

    settings = {
      context = {
        loadMemoryFromIncludeDirectories = true;
      };
      # general = {
      #   preferredEditor = "nvim";
      #   previewFeatures = true;
      #   vimMode = true;
      # };
      ide = {
        enabled = true;
      };
      privacy = {
        usageStatisticsEnabled = false;
      };
      security = {
        auth = {
          selectedType = "oauth-personal";
        };
      };
      tools = {
        autoAccept = false;
      };
      # ui = {
      #   theme = "Default";
      # };
    };
  };
}
