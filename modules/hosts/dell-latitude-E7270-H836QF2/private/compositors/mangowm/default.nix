{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {lib, ...}: {
      wayland.windowManager.mango.settings = lib.mapAttrs (_: value: lib.mkForce value) {
        monitorrule = [
          "name:^eDP-1$,width:1366,height:768,refresh:60,x:0,y:0,scale:1,vrr:0"
          "name:^HDMI-A-1$,x:1366,y:0,scale:1,vrr:0"
          "name:^HDMI-A-2$,x:1366,y:0,scale:1,vrr:0"
          "name:^HDMI-1$,x:1366,y:0,scale:1,vrr:0"
          "name:^HDMI-2$,x:1366,y:0,scale:1,vrr:0"
        ];

        # Disable GPU-heavy compositor effects.
        blur = 0;
        blur_layer = 0;
        animations = 0;
        layer_animations = 0;

        # Avoid alpha blending and decorative geometry.
        focused_opacity = 1.0;
        unfocused_opacity = 1.0;
        borderpx = 0;
        border_radius = 0;

        # Use the entire display and avoid gap calculations.
        gappih = 0;
        gappiv = 0;
        gappoh = 0;
        gappov = 0;
        smartgaps = 0;
      };
    };
  };
}
