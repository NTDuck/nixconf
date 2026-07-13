{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    nixos = {
      environment.sessionVariables = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1";
      };
    };

    homeManager = {
      imports = [
        inputs.mangowm.hmModules.mango
      ];

      wayland.windowManager.mango.settings.monitorrule = "name:^eDP-1$,width:2560,height:1600,refresh:165.019,scale:1.5,vrr:1";
    };
  };
}
