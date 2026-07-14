{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2.provides.to-users.homeManager = {
    lib,
    osConfig,
    ...
  }: {
    wayland.windowManager.mango.settings.monitorrule = lib.mkIf (osConfig.networking.hostName == "dell-latitude-E7270-H836QF2") (lib.mkForce "name:^eDP-1$,width:1366,height:768,refresh:60");
  };
}
