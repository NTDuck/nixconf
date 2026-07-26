{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2.homeManager = {lib, ...}: {
    wayland.windowManager.mango.settings = {
      monitorrule = lib.mkForce [
        "name:^eDP-1$,width:1366,height:768,refresh:60,x:0,y:0,scale:1,vrr:0"
        "name:^HDMI-A-1$,x:1366,y:0,scale:1,vrr:0"
        "name:^HDMI-A-2$,x:1366,y:0,scale:1,vrr:0"
        "name:^HDMI-1$,x:1366,y:0,scale:1,vrr:0"
        "name:^HDMI-2$,x:1366,y:0,scale:1,vrr:0"
      ];
    };
  };
}
