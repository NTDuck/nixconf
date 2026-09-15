{den, ...}: {
  den.aspects.apps.messenging = {
    includes = [
      den.aspects.apps.messenging.discord
      den.aspects.apps.messenging.lark-cli
      den.aspects.apps.messenging.telegram
      den.aspects.apps.messenging.zalo
    ];
  };
}
