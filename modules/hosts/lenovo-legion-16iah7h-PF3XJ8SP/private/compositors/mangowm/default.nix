{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {lib, ...}: {
      xresources.properties = {
        "Xft.dpi" = 144;
      };

      wayland.windowManager.mango.settings = {
        monitorrule = lib.mkForce [
          "name:^eDP-1$,width:2560,height:1600,refresh:165.019,x:0,y:0,scale:1.5,vrr:1"
          # HDMI externals: x:0,y:0 = SAME position as eDP-1 — mango's
          # output-layout overlap renders the mirrored clone (2026-09-23;
          # kanshi's mirror profiles apply the same position via
          # wlr-output-management, and the monitorrule must agree or
          # mango re-parks the output at creation). Previously x:1707
          # (extended desktop) which fought the kanshi mirror profiles.
          "name:^HDMI-A-1$,x:0,y:0,scale:1,vrr:0"
          "name:^HDMI-A-2$,x:0,y:0,scale:1,vrr:0"
          "name:^HDMI-1$,x:0,y:0,scale:1,vrr:0"
          "name:^HDMI-2$,x:0,y:0,scale:1,vrr:0"
        ];
      };
    };
  };
}
