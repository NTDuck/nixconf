{ inputs, ... }:

{
  imports = [
    inputs.ironbar.homeManagerModules.default
  ];

  programs.ironbar = {
    enable = true;
    config = {
      position = "left";
      start = [ { type = "workspaces"; } ];
      end = [ 
        { type = "volume"; }
        { type = "sys_info"; }
        { type = "clock"; format = "%d\n%m\n──\n%H\n%M"; }
      ];
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 10px;
      }
      /* Add your custom CSS styling here */
    '';
  };
}