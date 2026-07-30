{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {lib, ...}: {
      # Override for performance
      wayland.windowManager.mango.settings = lib.mapAttrs (_: value: lib.mkForce value) {
        monitorrule = [
          "name:^eDP-1$,width:1366,height:768,refresh:60,x:0,y:0,scale:1,vrr:0"
          "name:^HDMI-A-1$,x:1366,y:0,scale:1,vrr:0"
          "name:^HDMI-A-2$,x:1366,y:0,scale:1,vrr:0"
          "name:^HDMI-1$,x:1366,y:0,scale:1,vrr:0"
          "name:^HDMI-2$,x:1366,y:0,scale:1,vrr:0"
        ];

        blur = 0;
        blur_layer = 0;
        animations = 0;
        layer_animations = 0;

        focused_opacity = 1.0;
        unfocused_opacity = 1.0;
      };
    };
  };
}
