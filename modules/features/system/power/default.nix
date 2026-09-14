{den, ...}: {
  den.aspects.system.power.includes = [
    den.aspects.system.power.power-profiles-daemon
    den.aspects.system.power.powertop
    den.aspects.system.power.thermald
    den.aspects.system.power.throttled
    # den.aspects.system.power.tlp
    den.aspects.system.power.upower
  ];
}
