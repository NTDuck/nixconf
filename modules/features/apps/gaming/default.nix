{den, ...}: {
  den.aspects.apps.gaming = {
    includes = [
      den.aspects.apps.gaming.itch
      den.aspects.apps.gaming.mangohud
      den.aspects.apps.gaming.rpgmakermlinux-cicpoffs
      den.aspects.apps.gaming.romi
      # darling-lol un-included (2026-11-15, legion only): aspect declared
      # in darling-lol.nix; re-add explicitly per host to reactivate.
      den.aspects.apps.gaming.roleplaying
      den.aspects.apps.gaming.steam
      den.aspects.apps.gaming.wine
      den.aspects.apps.gaming.wlib
    ];
  };
}
