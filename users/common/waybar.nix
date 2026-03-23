{ ... }:

{
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "left";
        width = 35;
        
        modules-left = [ "river/tags" ];
        modules-right = [ "battery" "clock" ];
        
        "river/tags" = {
          num-tags = 9;
          tag-labels = [ "α" "β" "γ" "δ" "ε" "ζ" "η" "θ" "ι" ];
        };

        clock = {
          format = "{:%H\n%M}"; 
          tooltip-format = "{:%Y-%m-%d}";
        };
        
        battery = {
          states = { warning = 30; critical = 15; };
          format = "{capacity}%";
        };
      };
    };
    
    # Absolute minimal CSS to keep it looking clean and saving resources
    # style = ''
    #   * {
    #     font-family: monospace;
    #     font-size: 13px;
    #     color: #ffffff;
    #   }
    #   window#waybar {
    #     background-color: #111111;
    #   }
    #   #clock, #battery {
    #     padding: 10px 0;
    #   }
    #   #tags button {
    #     color: #555555;
    #     padding: 5px 0;
    #   }
    #   #tags button.focused {
    #     color: #ffffff;
    #     font-weight: bold;
    #   }
    # '';
  };
}
