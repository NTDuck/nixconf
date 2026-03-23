{ ... }:

{
  programs.yambar = {
    enable = true;
    
    settings = {
      bar = {
        location = "left";
        width = 85;
        font = "monospace:pixelsize=14";
        background = "111111ff";
        
        modules-left = [
          {
            clock = {
              time-format = "%H:%M";
              date-format = "%m-%d";
              content = [
                { string = { text = "{time}"; margin = 5; }; }
                { string = { text = "{date}"; margin = 5; }; }
              ];
            };
          }
          {
            battery = {
              name = "BAT0";
              poll-interval = 60;
              content = {
                string = { 
                  text = "BAT: {capacity}%"; 
                  margin = 5; 
                };
              };
            };
          }
        ];
      };
    };
  };
}
