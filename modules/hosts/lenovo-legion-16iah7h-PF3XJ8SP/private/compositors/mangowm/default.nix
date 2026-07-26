{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.homeManager = {lib, ...}: {
    wayland.windowManager.mango.settings = {
      monitorrule = lib.mkForce [
        "name:^eDP-1$,width:2560,height:1600,refresh:165.019,x:0,y:0,scale:1.5,vrr:1"
        "name:^HDMI-A-1$,x:1707,y:0,scale:1,vrr:0"
        "name:^HDMI-A-2$,x:1707,y:0,scale:1,vrr:0"
        "name:^HDMI-1$,x:1707,y:0,scale:1,vrr:0"
        "name:^HDMI-2$,x:1707,y:0,scale:1,vrr:0"
      ];
    };
  };
}
