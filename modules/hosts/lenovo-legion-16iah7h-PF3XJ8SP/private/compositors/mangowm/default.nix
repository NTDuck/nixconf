{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {lib, ...}: {
      xresources.properties = {
        "Xft.dpi" = 144;
      };

      wayland.windowManager.mango.settings = {
        monitorrule = lib.mkForce [
          "name:^eDP-1$,width:2560,height:1600,refresh:165.019,x:0,y:0,scale:1.5,vrr:1"
          "name:^HDMI-A-1$,x:1707,y:0,scale:1,vrr:0"
          "name:^HDMI-A-2$,x:1707,y:0,scale:1,vrr:0"
          "name:^HDMI-1$,x:1707,y:0,scale:1,vrr:0"
          "name:^HDMI-2$,x:1707,y:0,scale:1,vrr:0"
          # Sunshine "Desktop (dell-latitude-E7270-H836QF2)" app: the DELL
          # client's native panel is 1366x768@60. Mango applies CUSTOM modes
          # to headless outputs (monitor.c: rule->custom ||
          # wlr_output_is_headless), so this rule gives the stream target
          # its exact mode at creation — no host-side scaling, no eDP-1
          # mode flip while streaming. Parked right of the 1707px-wide
          # eDP-1 slot; sunshine's sun-dell-prep creates it and wlgrab
          # matches it by the output_name "SUNHEAD".
          "name:^SUNHEAD$,width:1366,height:768,refresh:60,x:1707,y:0,scale:1,vrr:0,custom:1"
        ];
      };
    };
  };
}
