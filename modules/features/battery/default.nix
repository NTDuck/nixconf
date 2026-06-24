{den, ...}: {
  den.aspects.battery.includes = [
    den.aspects.battery.fstrim
    den.aspects.battery.powertop
    den.aspects.battery.thermald
    den.aspects.battery.throttled
    den.aspects.battery.tlp
  ];
}
