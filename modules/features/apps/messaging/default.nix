{den, ...}: {
  den.aspects.apps.messaging = {
    includes = [
      den.aspects.apps.messaging.discord
      den.aspects.apps.messaging.lark-cli
      den.aspects.apps.messaging.telegram
      den.aspects.apps.messaging.zalo
    ];
  };
}
